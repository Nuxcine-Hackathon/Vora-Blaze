# Guide de contribution — VORA

## Branches

- `main` — toujours stable, déployable/démontrable
- `develop` — intégration continue de l'équipe
- `feature/authentication`
- `feature/map`
- `feature/booking`
- `feature/driver`
- `feature/security`
- `feature/ai` *(fonctionnalité d'innovation)*

Ne travaillez jamais directement sur `main`. Fusionnez vos `feature/*` dans `develop`,
puis `develop` dans `main` une fois testé.

## Commits

Format recommandé (Conventional Commits) :

```
feat: add user authentication
feat: integrate map
feat: add ride booking
fix: correct route calculation
feat: add SOS button
docs: update installation guide
```

## Règle d'or

Chaque membre doit committer régulièrement sous son propre nom — les contributions
GitHub individuelles font partie de l'évaluation du travail d'équipe.
