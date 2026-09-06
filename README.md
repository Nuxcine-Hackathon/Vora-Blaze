# OnTravel — Hackathon NuxCine 2026 (défi VORA)

Application de mobilité intelligente pensée pour les réalités urbaines camerounaises : réservation voiture/moto, prix estimé avant de réserver, paiement Mobile Money, suivi en temps réel, et fonctionnalités de sécurité (bouton SOS, partage de trajet).

---

## 1. Présentation

OnTravel met en relation passagers et chauffeurs à Douala et Yaoundé. Trois surfaces composent le projet :

| Composant | Techno | Chemin |
|---|---|---|
| App Passager | Flutter | [`Code/App/rideon-rider-app-production_1.3`](Code/App/rideon-rider-app-production_1.3) |
| App Chauffeur | Flutter | [`Code/App/rideon-driver-app-production_1.3`](Code/App/rideon-driver-app-production_1.3) |
| Backend + Admin | Laravel 12 / PHP 8.3 | [`Code/Admin/Admin_Install`](Code/Admin/Admin_Install) |
| Landing page | PHP statique | [`Code/Landing/Landing`](Code/Landing/Landing) |

## 2. Problème

Les applications de VTC disponibles sont pensées pour d'autres marchés : adresses formelles inexistantes en pratique (on se repère par quartier/carrefour), paiement par carte bancaire peu répandu, une seule langue, et aucune option économique adaptée aux embouteillages urbains où la moto-taxi est souvent le moyen le plus rapide.

## 3. Notre solution

OnTravel adapte chaque maillon du parcours à ces réalités : choix voiture **ou moto**, prix affiché en FCFA avant la réservation (calcul incluant le trafic en temps réel), paiement **Mobile Money** en premier plan, interface bilingue français/anglais (français par défaut), et des mécanismes de sécurité actifs pendant la course (SOS, partage de trajet).

## 4. Fonctionnalités

**Passager** : inscription/connexion par téléphone + OTP, géolocalisation, carte interactive, choix voiture/moto, calcul d'itinéraire et estimation de prix (trafic en temps réel), réservation, suivi du chauffeur en direct, historique, profil, notation, assistance, bouton SOS et partage de trajet.

**Chauffeur** : connexion, tableau de bord, disponibilité (en/hors service), réception et acceptation des demandes, navigation vers le passager, fin de course, revenus et paiements, historique, profil, sécurité.

**Administration** (panel web) : gestion des utilisateurs, chauffeurs, véhicules, courses, finances/commissions, paramètres généraux, statistiques.

## 5. Innovation

- **Mobile Money natif** — le paiement en ligne est explicitement du Mobile Money (MTN/Orange), pas une carte bancaire, avec un mode démo réaliste sans dépendre d'un compte marchand réel pendant le hackathon.
- **Sécurité active pendant la course** — bouton SOS *et* un bouton "Partager ma course" qui envoie par WhatsApp le nom/plaque du chauffeur, le départ/destination et un lien Google Maps vers sa position la plus récente à un proche.
- **Annonces vocales** — les changements de statut d'une course ("chauffeur accepté", "course commencée", "vous êtes arrivé") sont aussi annoncés à voix haute en français, utile en conduisant comme pour l'accessibilité.
- **Assistant IA embarqué** — un assistant conversationnel (Google Gemini) intégré à l'app répond en français/anglais aux questions sur la réservation, le paiement Mobile Money ou la sécurité ; la clé API reste côté serveur, jamais exposée au client.
- **Estimation consciente du trafic** — le prix affiché avant réservation intègre déjà le trafic en temps réel (Google Directions, `departure_time=now`), pas une estimation à distance fixe.
- **Repères locaux** — sélection rapide de quartiers/lieux connus de Douala/Yaoundé en complément de l'autocomplétion classique.
- **Bilingue par conception** — français par défaut, anglais disponible, cohérent avec la réalité camerounaise.

## 6. Sécurité

- Authentification API par jeton Sanctum ; un bug hérité du modèle de base (un alias de middleware mal nommé qui laissait passer des requêtes non authentifiées sur toute l'API mobile) a été identifié et corrigé.
- Aucun secret n'est commité dans le dépôt : clés API et identifiants passent par `.env` (voir `.env.example`), jamais en dur dans le code.
- Bouton SOS et partage de trajet côté passager et chauffeur.
- Validation des entrées côté API (Form Requests Laravel) et côté application (Flutter).
- Séparation des rôles : guard `web` pour l'administration, guard `appUser` + jetons Sanctum pour l'API mobile.

## 7. Architecture

```
        App Passager (Flutter)       App Chauffeur (Flutter)
                    │                         │
                    └───────────┬─────────────┘
                                 ▼
                        API Laravel (Sanctum)
                                 │
                ┌────────────────┼─────────────────┐
                ▼                ▼                  ▼
         MySQL/MariaDB   Firebase (Auth temps    Google Maps /
        (données métier)  réel, position,        Directions API
                           notifications)
                                 │
                                 ▼
                        Panel Administration
                             (Laravel Blade)
```

Le cœur de VORA est un problème relationnel (utilisateurs, courses, paiements, commissions) autant que temps réel (position du chauffeur, statut de course). D'où le choix : **MySQL pour les données métier structurées** (via l'API Laravel/Sanctum, avec toute la logique de tarification, de matching et de reporting déjà en place) et **Firebase uniquement pour ce qu'il fait le mieux** — la diffusion temps réel de la position et des notifications push, sans réécrire un système d'API complet. Le suivi de position et les mises à jour de statut de course transitent par Firebase (Realtime Database/Firestore) en complément de l'API REST Laravel pour les opérations métier (réservation, paiement, historique).

## 8. Technologies

- **Mobile** : Flutter 3.38, flutter_bloc (Cubit), Hive (cache local), Firebase (Auth, Realtime Database, Firestore, Messaging), Google Maps SDK, OneSignal.
- **Backend** : Laravel 12, PHP 8.3, MySQL/MariaDB, Laravel Sanctum, Spatie MediaLibrary.
- **Paiement** : PayDunya (agrégateur Mobile Money Afrique de l'Ouest/Centrale), en mode démo pour le hackathon.
- **Cartographie** : Google Maps Platform (Maps SDK, Directions API avec trafic temps réel, Places).
- **IA** : Google Gemini (modèle Flash), pour l'assistant conversationnel embarqué.
- **Design** : Figma — voir section 19.

## 9. Installation

Prérequis : PHP **8.3+** (le projet ne démarre pas sur 8.2, voir note ci-dessous), Composer, MySQL/MariaDB, Flutter 3.38+, Node.js (pour les outils Firebase optionnels).

```bash
git clone <url-du-depot>
cd Vora-Blaze
```

**Backend Laravel :**

```bash
cd Code/Admin/Admin_Install
composer install
cp .env.example .env
php artisan key:generate
```

> **Note PHP** : les dépendances verrouillées (`composer.lock`) exigent PHP ≥ 8.3. Si votre PHP par défaut est en 8.2 (ex. certaines installations XAMPP), utilisez un binaire 8.3+ explicite pour toutes les commandes `composer`/`artisan` ci-dessous.
>
> **Note Windows/SSL** : si les appels sortants HTTPS (ex. l'assistant IA) échouent avec `cURL error 60: SSL certificate problem`, c'est un souci classique de bundle de certificats manquant sous Windows. Le projet embarque déjà `storage/certs/cacert.pem` et le contrôleur l'utilise directement — aucune configuration `php.ini` n'est nécessaire pour ce point précis.

**Apps Flutter (passager et chauffeur), depuis chacun des deux dossiers d'app :**

```bash
cd Code/App/rideon-rider-app-production_1.3   # puis répéter pour rideon-driver-app-production_1.3
flutter pub get
```

## 10. Configuration

1. Copiez `Code/Admin/Admin_Install/.env.example` vers `.env` et renseignez les variables (section 11).
2. Dans chaque app Flutter, éditez `lib/core/services/config.dart` : `baseUrl` doit pointer vers votre instance backend, et `googleKey`/`oneSiginalAppid`/`oneSiginalApiKey` doivent être renseignés avec vos propres clés (des placeholders `YOUR_..._HERE` sont présents par défaut).
3. Google Maps : activez les API "Maps SDK for Android/iOS", "Directions API" et "Places API" sur votre projet Google Cloud.
4. Firebase : chaque app Flutter a besoin de son propre `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) — déjà présents dans ce dépôt pour le projet Firebase du hackathon ; remplacez-les si vous utilisez votre propre projet Firebase.
5. **Accès partagé pour l'équipe** : tant qu'aucune décision d'équipe n'est prise sur un déploiement commun, chaque membre peut lancer le backend en local (`php artisan serve`) et l'exposer temporairement via un tunnel (ex. `ngrok http 8000`) pour que les autres testent contre son instance sans redéployer une base à chaque fois. *À trancher en équipe.*

## 11. Variables d'environnement

Voir [`Code/Admin/Admin_Install/.env.example`](Code/Admin/Admin_Install/.env.example) pour la liste complète et commentée. Points clés :

| Variable | Rôle |
|---|---|
| `APP_URL` | URL publique du backend, utilisée par les deux apps mobiles |
| `DB_*` | Connexion MySQL/MariaDB |
| `APP_SHARED_SECRET` | Secret partagé app↔API pour l'échange de jeton (voir `TokenController`) |
| `PAYDUNYA_MODE` | `demo` (par défaut, aucune transaction réelle) ou `live`/`sandbox` avec de vraies clés |
| `PAYDUNYA_MASTER_KEY` / `PAYDUNYA_PRIVATE_KEY` / `PAYDUNYA_TOKEN` | Identifiants PayDunya réels (uniquement si `PAYDUNYA_MODE` ≠ `demo`) |
| `GEMINI_API_KEY` / `GEMINI_MODEL` | Clé Google AI Studio pour l'assistant IA (gratuite, voir aistudio.google.com/apikey) |
| `LANDING_URL` | URL de la landing page, affichée dans le lien "Visiter le site" de l'admin |

**Aucune clé réelle n'est présente dans `.env.example` ni committée dans le dépôt.**

## 12. Base de données

Un dump complet du schéma est fourni : [`Code/Admin/Admin_Install/installer/rideon.sql`](Code/Admin/Admin_Install/installer/rideon.sql).

```bash
mysql -u root -e "CREATE DATABASE ontravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root ontravel < Code/Admin/Admin_Install/installer/rideon.sql
```

Puis, pour peupler les catégories de véhicules (voiture/moto — la table en est vide dans le dump brut) et les autres données de démonstration :

```bash
cd Code/Admin/Admin_Install
php artisan db:seed
```

## 13. Lancement du projet

**Backend :**

```bash
cd Code/Admin/Admin_Install
php artisan serve --port=8000
```

Panel admin disponible sur `http://127.0.0.1:8000/admin`.

**Apps Flutter :** définissez `baseUrl` (section 10) puis, depuis le dossier de chaque app :

```bash
flutter run
```

## 14. Comptes de démonstration

```
ADMIN (panel web)
Email    : admin@sizhitsolutions.com
Mot de passe : OnTravel@2026
```

> Identifiants de démonstration uniquement — à changer avant toute mise en production.

**Passager / Chauffeur** : l'authentification mobile se fait par numéro de téléphone + code OTP (pas de mot de passe). Pour la démonstration, le paramètre admin `auto_fill_otp` est activé par défaut : le code OTP généré est renvoyé directement dans la réponse de l'API lors de l'inscription/connexion, ce qui permet de tester le flux complet sans passerelle SMS réelle.

## 15. Structure du projet

```
Vora-Blaze/
├── .github/                # Templates d'issues / de pull request
├── CONTRIBUTING.md         # Convention de branches et de commits de l'équipe
└── Code/
    ├── Admin/Admin_Install/   # Backend Laravel + panel admin (MVC, app/Strategies pour les paiements)
    ├── App/
    │   ├── rideon-rider-app-production_1.3/   # App passager Flutter (lib/{app,core,data,domain,presentation})
    │   └── rideon-driver-app-production_1.3/  # App chauffeur Flutter, même organisation
    └── Landing/Landing/       # Landing page PHP statique
```

## 16. API utilisées

- **Google Maps Platform** — géocodage, autocomplétion d'adresses, calcul d'itinéraire et prix avec trafic temps réel.
- **Firebase** (Auth, Realtime Database, Firestore, Cloud Messaging) — position des chauffeurs en direct, statut de course, notifications push.
- **OneSignal** — notifications push complémentaires.
- **PayDunya** — paiement Mobile Money (mode démo dans cette configuration).
- **Google Gemini API** — assistant conversationnel.

## 17. Limites connues

- Le paiement Mobile Money fonctionne en **mode démo** (aucun identifiant marchand réel configuré) — le flux est complet et réaliste à l'écran, sans mouvement d'argent réel.
- Les repères locaux rapides couvrent un échantillon de lieux connus de Douala/Yaoundé, pas une base exhaustive.
- L'assistant IA dépend du palier gratuit de l'API Gemini (limites de requêtes/minute).
- Partage de trajet, annonces vocales et assistant IA sont implémentés côté application **passager** ; l'application chauffeur n'a pas encore ces trois écrans (le bouton SOS existe des deux côtés).
- Les identifiants natifs des applications (`applicationId` Android, bundle iOS) ont été conservés tels quels pour ne pas casser la configuration Firebase existante ; seuls le nom affiché, l'icône et l'identité visuelle ont été changés.
- Le fichier Figma ne couvre pas la totalité de la liste de référence du manuel (non exigée par le règlement) mais un ensemble représentatif des trois parcours (passager, chauffeur, admin) — voir section 19.
- Le mode d'accès partagé au backend pour les tests d'équipe (ngrok vs déploiement) n'est pas encore tranché — voir section 10.

## 18. Membres de l'équipe

| Nom | Rôle |
|---|---|
| Djouko Socrate | Développeur full-stack — architecture, backend, apps mobiles, sécurité |
| _À compléter_ | _À compléter_ |
| _À compléter_ | _À compléter_ |
| _À compléter_ | _À compléter_ |
| _À compléter_ | _À compléter_ |

## 19. Figma

Maquettes et système de design : **[OnTravel — Maquettes](https://www.figma.com/design/nlm15vOL65Y8dzORXKbh6r)**

Écrans couverts : Passager (Accueil, Estimation de course, Suivi de course avec SOS/partage), Chauffeur (Tableau de bord avec demande de course entrante). Palette, typographie (Poppins/Work Sans) et composants définis en variables Figma réutilisables.

## 20. Démonstration

Parcours recommandé pour la présentation :
1. Panel admin (section 14) → aperçu des courses/utilisateurs/statistiques.
2. App passager : inscription par téléphone → accueil → sélection d'un repère local → estimation voiture/moto en FCFA → réservation → suivi en direct (annonces vocales à chaque changement de statut) → bouton SOS/partage de trajet.
3. App chauffeur : passage en service → réception d'une demande → acceptation → navigation → fin de course → revenus.
4. Paiement Mobile Money en mode démo lors de la confirmation de course.
5. Assistant IA (menu passager) : poser une question sur la réservation ou le paiement.

---

*Projet développé par Djouko Socrate pour le Hackathon NuxCine 2026, défi VORA.*
