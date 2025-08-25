# État d'avancement du projet Exokin

Ce document récapitule l'état actuel du projet Exokin, les fonctionnalités implémentées et celles qui restent à développer.

## 1. Fonctionnalités implémentées

### Général
- Initialisation du projet Flutter (frontend) et Node.js/Express (backend).
- Configuration de la base de données avec Prisma (SQLite pour le développement local).
- Communication établie entre le frontend et le backend.

### Frontend (Flutter)
- **Interface principale (onglet "Principal") :**
    - Affichage d'un tableau d'exercices avec 3 lignes par défaut au démarrage.
    - Ajout de nouvelles lignes vides au tableau via le bouton `+`.
    - Suppression de lignes du tableau.
    - Champs éditables pour :
        - Nom de l'exercice (avec autocomplétion basée sur la base d'exercices).
        - Répétitions, Séries, Pause (s), Tempo, Remarques.
    - Sélection des jours de la semaine via un menu déroulant multi-sélection avec cases à cocher et abréviations (Lu, Ma, Me, etc.).
    - Bouton "Sauvegarder" pour enregistrer le programme actuel (les exercices du tableau) dans la base de données des programmes, avec une invite pour le nom du programme.
    - Bouton "Imprimer" fonctionnel, générant un PDF du programme actuel.
- **Onglet "Programmes" :**
    - Affichage de la liste des programmes enregistrés.
    - Possibilité de charger un programme existant dans le tableau principal.
    - Possibilité de supprimer un programme entier.
- **Onglet "Exercices" :**
    - Affichage de la liste des exercices de base (nom, articulations, muscles).
    - Ajout de nouveaux exercices de base via le bouton `+`, avec champs pour le nom, les articulations et les muscles.
    - Édition des exercices existants via un bouton "Modifier", permettant de changer le nom, les articulations et les muscles.
    - Possibilité de supprimer un exercice de base.

### Backend (Node.js/Express)
- **API RESTful pour :**
    - Gestion des programmes (Protocoles) : `GET /protocols`, `POST /protocols`, `DELETE /protocols/:id`.
    - Gestion des exercices de base : `GET /exercises`, `POST /exercises`, `PUT /exercises/:id`, `DELETE /exercises/:id`.
    - Gestion des exercices au sein d'un protocole : `POST /protocols/:protocolId/exercises`, `DELETE /protocol-exercises/:id`.
- **Intégration de Prisma ORM :**
    - Modèles `Protocol`, `Exercise`, `ProtocolExercise` définis et synchronisés avec la base de données.
    - Conversion des champs `days`, `articulation`, `muscles` entre tableaux (frontend) et chaînes de caractères (backend/DB).

## 2. Ce qu'il reste à faire

- **Améliorations de l'interface utilisateur :**
    - Améliorer l'expérience utilisateur pour la sélection des jours (le `MultiSelectDropdown` actuel est fonctionnel mais pourrait être plus intégré visuellement).
    - Validation des champs de saisie (ex: s'assurer que les répétitions sont des nombres).
    - Améliorer la gestion des erreurs et les messages à l'utilisateur.
- **Fonctionnalités supplémentaires (selon les besoins futurs) :**
    - Authentification des utilisateurs et gestion des rôles (kiné, patient).
    - Ajout de plus de détails aux exercices (images, vidéos, descriptions longues).
    - Fonctionnalités de recherche avancée pour les programmes et exercices.
    - Export/Import de données.
