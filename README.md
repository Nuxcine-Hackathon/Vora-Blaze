# VORA — Blaze

> Solution de mobilité intelligente adaptée au contexte camerounais.
> Projet réalisé dans le cadre du **NuxCine Hackathon 2026** (48h).

---

## 1. Présentation

VORA est une plateforme de VTC (Voiture de Transport avec Chauffeur) pensée pour les réalités
du marché camerounais : connexion Internet instable, précision GPS variable, sensibilité au
prix, diversité des moyens de paiement, sécurité des usagers.

Ce dépôt contient :
- l'application mobile **Passager** (Flutter)
- l'application mobile **Chauffeur** (Flutter)
- le **back-office Administrateur** (web)
- le **back-end** (Firebase : Auth, Firestore, Cloud Functions, FCM)
- la documentation technique et produit

## 2. Problème

*(À compléter par l'équipe — 3 à 5 phrases sur le problème identifié : difficulté à trouver un
chauffeur fiable, prix imprévisible, sécurité, mauvaise couverture réseau, etc.)*

## 3. Notre solution

*(À compléter — comment VORA répond au problème. Résumez le parcours utilisateur principal.)*

## 4. Fonctionnalités

### MVP (Priorité critique — voir `docs/MVP_SCOPE.md`)
- [ ] Authentification (passager / chauffeur)
- [ ] Géolocalisation & carte
- [ ] Demande de course & matching
- [ ] Estimation & calcul du prix
- [ ] Suivi de course en temps réel
- [ ] Paiement (réel ou simulé)
- [ ] Historique & évaluation

### Priorité élevée
- [ ] Annulation avec gestion des frais
- [ ] Back-office administrateur
- [ ] Support / assistance

### Fonctionnalité(s) d'innovation
*(À compléter — décrivez votre fonctionnalité différenciante, voir `docs/INNOVATION.md`)*

## 5. Innovation

*(À compléter — voir section 11 du manuel du hackathon pour des pistes : IA, accessibilité,
contexte camerounais, sécurité intelligente, etc.)*

## 6. Sécurité

- Authentification sécurisée (Firebase Auth, OTP téléphone)
- Règles d'accès strictes côté base de données (Firestore Security Rules)
- Aucune clé API ni secret dans le dépôt (voir `.env.example`)
- Bouton SOS / partage de course *(si implémenté)*
- Validation des entrées côté client et côté Cloud Functions

Détails complets : `docs/SECURITY.md`

## 7. Architecture

```
APPLICATION PASSAGER (Flutter)
APPLICATION CHAUFFEUR (Flutter)
            │
            ▼
   FIREBASE (Auth, Firestore, Cloud Functions, FCM)
            │
   ┌────────┼─────────────┐
   ▼        ▼             ▼
Firestore  Maps/GPS   Cloud Functions
(données)  (Google    (logique métier,
            Maps/       matching, tarif,
            Mapbox)     notifications)
            │
            ▼
   ADMIN DASHBOARD (web)
```

Schéma détaillé et justification des choix : `docs/ARCHITECTURE.md`

## 8. Technologies

| Composant            | Techno                                   |
|-----------------------|-------------------------------------------|
| Mobile Passager       | Flutter                                   |
| Mobile Chauffeur      | Flutter                                   |
| Back-office Admin     | *(à définir — ex. React/Next.js)*         |
| Back-end / BaaS       | Firebase (Auth, Firestore, Cloud Functions, FCM) |
| Cartographie          | *(à définir — Google Maps Platform / Mapbox)* |
| Design                | Figma                                     |

## 9. Installation

Prérequis :
- Flutter SDK (>= 3.x) — `flutter --version`
- Node.js (>= 18) pour les Cloud Functions
- Un projet Firebase créé sur [console.firebase.google.com](https://console.firebase.google.com)
- Firebase CLI : `npm install -g firebase-tools`

```bash
git clone <URL_DU_DEPOT>
cd vora
```

### App Passager
```bash
cd apps/passenger_app
flutter pub get
```

### App Chauffeur
```bash
cd apps/driver_app
flutter pub get
```

### Back-end (Firebase Functions)
```bash
cd backend/firebase/functions
npm install
```

### Back-office Admin
```bash
cd admin_dashboard
npm install
```

## 10. Configuration

1. Créez un projet Firebase.
2. Activez : Authentication (téléphone + email), Firestore, Cloud Functions, Cloud Messaging.
3. Téléchargez les fichiers de config :
   - `google-services.json` → `apps/passenger_app/android/app/` et `apps/driver_app/android/app/`
   - `GoogleService-Info.plist` → équivalent iOS
4. Copiez `.env.example` en `.env` dans chaque app et remplissez les valeurs.

## 11. Variables d'environnement

Voir `.env.example` à la racine. Ne jamais committer de vraies clés.

```
MAPS_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_API_KEY=
FIREBASE_APP_ID=
```

## 12. Base de données

Firestore (NoSQL). Collections principales : voir `docs/DATA_MODEL.md`.

Pour lancer les émulateurs Firebase en local :
```bash
cd backend/firebase
firebase emulators:start
```

## 13. Lancement du projet

```bash
# App Passager
cd apps/passenger_app && flutter run

# App Chauffeur
cd apps/driver_app && flutter run

# Back-end (émulateurs Firebase)
cd backend/firebase && firebase emulators:start

# Back-office Admin
cd admin_dashboard && npm run dev
```

## 14. Comptes de démonstration

```
PASSAGER
Email : demo-passager@vora.test
Mot de passe : Demo1234!

CHAUFFEUR
Email : demo-chauffeur@vora.test
Mot de passe : Demo1234!

ADMIN
Email : demo-admin@vora.test
Mot de passe : Demo1234!
```
*(Utilisez uniquement des comptes de test — jamais de vraies données personnelles.)*

## 15. Structure du projet

```
vora/
├── apps/
│   ├── passenger_app/     # App Flutter — Passager
│   └── driver_app/        # App Flutter — Chauffeur
├── admin_dashboard/        # Back-office web Administrateur
├── backend/
│   └── firebase/
│       ├── functions/      # Cloud Functions (matching, tarification, notifications)
│       └── firestore/      # Règles de sécurité & indexes
├── docs/                   # Documentation produit & technique
└── scripts/                # Scripts utilitaires (seed data, etc.)
```

## 16. API utilisées

- *(ex. Google Maps Platform / Mapbox — géolocalisation, itinéraires)*
- *(ex. Firebase Cloud Messaging — notifications push)*
- *(ex. API Mobile Money / paiement simulé)*

## 17. Limites

*(À compléter avant la soumission — soyez honnêtes sur ce qui est simulé, non testé,
ou incomplet. Le jury valorise la transparence.)*

## 18. Membres de l'équipe

| Nom | Rôle |
|-----|------|
|     | Team Lead / Full-stack |
|     | Frontend / Mobile |
|     | Backend |
|     | UI/UX / Product Designer |
|     | Innovation / QA / Sécurité |

## 19. Figma

Lien du fichier Figma : *(à compléter)*

## 20. Démonstration

*(Lien vidéo ou instructions de démo pour le jury)*
