# VORA — Blaze

Backend Node/Express + Supabase pour le projet **VORA** (Hackathon NuxCine 2026, Équipe Blaze).
Réalisé par **Edwards** (backend, coordination, déploiement), en binôme avec **Socrate** (frontend).

## 1. Présentation

API REST qui gère : authentification (OTP simulé), estimation et cycle de vie des courses (prix
verrouillé), disponibilité et position des chauffeurs, paiements et évaluations simulés, alertes
SOS / détection d'écart de trajet, et un assistant conversationnel basé sur la détection
d'intentions (branché sur le module IA de Franck).

## 2. Architecture

```
Client / Chauffeur (app Socrate)
        │
        ▼
   API Express (ce repo)
        │
   ┌────┴────┐
   ▼         ▼
Supabase   Assistant IA (Franck)
(Postgres)  (mock ou service externe)
```

## 3. Technologies

- Node.js + Express
- Supabase (Postgres + Auth via service role key côté serveur)
- JWT pour l'authentification
- express-validator, helmet, express-rate-limit pour la sécurité

## 4. Installation

```bash
git clone <votre-repository>
cd vora-backend
npm install
```

## 5. Configuration

Copiez le fichier d'exemple et remplissez vos propres valeurs (jamais commitées) :

```bash
cp .env.example .env
```

Variables à renseigner dans `.env` :

| Variable | Description |
|---|---|
| `SUPABASE_URL` | URL de votre projet Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Clé service role (Project Settings > API) |
| `JWT_SECRET` | Chaîne aléatoire longue pour signer les tokens |
| `ASSISTANT_MODE` | `mock` (par défaut) ou `llm` si Franck branche un vrai service |
| `CORS_ORIGIN` | URL(s) du frontend, séparées par des virgules |

**Ne jamais mettre de vraies clés dans GitHub.**

## 6. Base de données

1. Créez un projet sur [supabase.com](https://supabase.com).
2. Ouvrez **SQL Editor** et exécutez le contenu de `supabase/schema.sql`.
3. Vous devez voir apparaître 7 tables : `users`, `vehicles`, `trips`, `payments`, `ratings`,
   `alerts`, `assistant_logs`.
4. Ajoutez Socrate et Franck comme collaborateurs (Project Settings > Team) pour qu'ils puissent
   lire le schéma sans avoir les clés de prod.

## 7. Lancement du projet

```bash
npm run dev     # avec rechargement automatique (nodemon)
# ou
npm start       # mode production
```

Vérifiez que le serveur répond :

```bash
curl http://localhost:4000/health
```

## 8. Comptes de démonstration

Aucun compte n'est pré-créé : utilisez `POST /auth/register` puis `POST /auth/verify-otp`
(le code OTP est renvoyé directement dans la réponse en mode démo — pas de vrai SMS envoyé).

## 9. Aperçu des routes

| Méthode | Route | Description |
|---|---|---|
| GET | `/health` | Vérifie que le serveur tourne |
| POST | `/auth/register` | Créer un compte (client/chauffeur/admin) |
| POST | `/auth/verify-otp` | Vérifier le code OTP simulé |
| POST | `/auth/login` | Connexion, renvoie un JWT |
| POST | `/trips/estimate` | Estimation de prix (ne crée rien en base) |
| POST | `/trips` | Créer une course (prix verrouillé) |
| GET | `/trips` | Historique des courses de l'utilisateur connecté |
| GET | `/trips/pending` | Courses en attente d'un chauffeur (statut recherche_chauffeur) |
| GET | `/trips/:id` | Détail d'une course |
| PATCH | `/trips/:id/accept` | Un chauffeur accepte une course |
| PATCH | `/trips/:id/start` | Démarrer une course |
| PATCH | `/trips/:id/end` | Terminer une course |
| PATCH | `/trips/:id/cancel` | Annuler une course |
| POST | `/trips/:id/check-deviation` | Vérifier un écart de trajet |
| PUT | `/drivers/status` | Basculer en ligne / hors ligne |
| PUT | `/drivers/position` | Mettre à jour la position GPS |
| GET | `/drivers/nearby` | Chauffeurs disponibles à proximité |
| POST | `/payments` | Simuler un paiement |
| GET | `/payments/:tripId` | Récupérer le paiement d'une course |
| POST | `/ratings` | Évaluer un utilisateur après une course |
| GET | `/ratings/user/:userId` | Note moyenne d'un utilisateur |
| POST | `/alerts/sos` | Déclencher une alerte SOS |
| POST | `/assistant` | Poser une question à l'assistant IA |

Toutes les routes protégées attendent l'en-tête : `Authorization: Bearer <token>`.
Une collection Postman peut être exportée à partir de ces routes pour les tests d'équipe.

## 10. Déploiement

Le fichier `render.yaml` est prêt pour un déploiement sur [Render](https://render.com) :

1. Connectez votre dépôt GitHub à Render.
2. Render détecte `render.yaml` et crée le service automatiquement.
3. Renseignez les variables marquées `sync: false` dans le dashboard Render (jamais dans le repo).
4. Déployez — vous obtenez une URL publique type `https://vora-backend.onrender.com`.

(Alternative équivalente : Railway.)

## 11. Sécurité

- `helmet` pour les en-têtes HTTP sécurisés.
- `express-rate-limit` : limite générale + limite stricte anti brute-force sur `/auth/*`.
- Validation systématique des entrées via `express-validator`.
- Mots de passe hashés avec `bcryptjs`, jamais stockés en clair.
- Authentification par JWT, séparation des rôles (`client`, `chauffeur`, `admin`).
- Aucun secret dans le code : tout passe par `.env` (voir `.env.example`).

## 12. Limites connues (MVP hackathon)

- OTP simulé (pas d'envoi SMS réel) — Twilio trial recommandé si le temps le permet.
- Paiements et notations simulés, pas de vrai prestataire de paiement intégré.
- `nearby` filtre les chauffeurs côté Node (pas de PostGIS) — suffisant pour le volume du MVP.
- L'assistant IA fonctionne en mode "mock" par mots-clés tant que Franck n'a pas branché un
  service LLM réel (`ASSISTANT_MODE=llm`).
- Mécanisme de compensation des chauffeurs (annulations) non implémenté dans ce MVP — prévu en V2.

## 13. Équipe

- **Edwards** — Backend, répartition des tâches, mise en ligne
- **Socrate** — Frontend (app client/chauffeur)
- **Elisabeth** — Design UI (Figma)
- **Dassi** — Design UX + personnage assistant
- **Franck** — Assistant IA
