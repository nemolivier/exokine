# Projet d'Application Web et Mobile

Ce document décrit l'architecture et la stack technologique proposées pour le développement d'une application multiplateforme (Web, iOS, Android).

## 1. Objectifs

- **Multiplateforme :** Une seule base de code pour le web et les applications mobiles.
- **Interface Utilisateur :** Moderne, expressive et suivant les directives de Material Design 3 (M3).
- **Backend :** Robuste, capable de gérer une logique métier et des connexions à une base de données.
- **Sécurité :** Authentification et communication sécurisées.
- **Hébergement :** Déployable sur des serveurs standards.

## 2. Stack Technologique Recommandée

### Frontend : Flutter

- **Framework :** [Flutter](https://flutter.dev/)
- **Langage :** Dart
- **Pourquoi ?**
    - **Performance Native :** Compile en code natif ARM/x86 et JavaScript pour des performances optimales sur toutes les plateformes.
    - **Base de Code Unique :** Réduit considérablement le temps et le coût de développement et de maintenance.
    - **Material Design 3 Natif :** Flutter est le framework de référence de Google pour Material Design. L'intégration est transparente et complète.
    - **UI Expressive :** Permet de créer facilement des interfaces riches et animées, conformément au style "Expressive" de M3.

### Backend : Node.js & Express.js

- **Framework :** [Express.js](https://expressjs.com/) sur [Node.js](https://nodejs.org/)
- **Langage :** TypeScript (pour la robustesse et la maintenabilité)
- **Pourquoi ?**
    - **Haute Performance :** Architecture non bloquante, idéale pour les applications I/O intensives (API, websockets).
    - **Écosystème Riche :** Accès à l'immense écosystème de paquets `npm` pour accélérer le développement.
    - **Flexibilité :** S'intègre facilement avec tout type de base de données.

### Base de Données : PostgreSQL

- **SGBD :** [PostgreSQL](https://www.postgresql.org/)
- **Pourquoi ?**
    - **Fiabilité et Robustesse :** Réputation d'être l'un des SGBD relationnels les plus avancés et fiables.
    - **Flexibilité :** Supporte les données relationnelles (SQL) et non relationnelles (JSON).
    - **Open Source :** Pas de coût de licence.

## 3. Architecture de Sécurité

- **Authentification :** Tokens JWT (JSON Web Tokens) échangés via des en-têtes `Authorization`.
- **Mots de passe :** Hachage sécurisé avec `bcrypt`.
- **Communication :** HTTPS/TLS obligatoire entre le client et le serveur.

## 5. MCP

- **Usage**
autant que possible, utiliser les informations spécifiques aux langages utilisés fournis par le serveur ncp disponible : Context7


## 6. Projet

### **Général : ** Application destinée à la prescription d’exercices de kiné

### **Usage : ** Simple et rapide, interface claire, Material Design le plus récent

### **Structure :** Fondé sur 2 bases de donées : une contenant des exercices, une autre contenant des programmes

    - **Exercices :** Un exercice contient :
        - nom
        - articulations impliquées
        - muscles impliqués
    - **Programme :** Un programme est un ensemble d’exercices il contient :
        - nom
        - mots clef 

### **Inerface principale**

La page principale est un tableau comportant un exerice par ligne
Il est possible :
- d’effacer une ligne
- d’ajouter une ligne

Les colonnes du tableau sont :
- jour de la semaine où l’exercice doit être fait (liste déroulante des jours de la semaine)
- nom de l’exercice
- nombre de répétitions
- nombre de séries
- temps de pause entre les séries
- tempo de l’exercice
- remarques

Il y a un bouton "imprimer" qui imprime le tableau sur une page au format A4, en mode paysage

Il y a un bouton "sauvegarder" qui sauvegarde le tableau exercice dans un programme, dans la base de donnée programme.

Il y a 2 autres onglets sur la page principale :
- un onglet "programme" qui donne accès à la liste des programmes
- un onglet "exercice" qui donne accès à la liste des exercices



## 4. Prochaines Étapes

1.  **Initialiser le projet Flutter :** `flutter create .`
2.  **Mettre en place la structure du projet backend** avec Node.js, Express et TypeScript.
3.  **Développer un premier écran** simple sur Flutter pour valider la configuration.
4.  **Créer une première route API** sur le backend (ex: `/api/health`).
5.  **Connecter l'application Flutter** au backend.
