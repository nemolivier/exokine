# Déployer l'application Exokin en local

Ce guide vous explique comment installer et lancer le projet Exokin sur votre machine locale pour le développement.

## 1. Prérequis

Avant de commencer, assurez-vous d'avoir installé les logiciels suivants sur votre système :

- **Git :** Pour cloner le projet depuis le dépôt. [Télécharger Git](https://git-scm.com/downloads)
- **Node.js et npm :** Pour faire fonctionner le backend. Node.js version 16 ou supérieure est recommandée. [Télécharger Node.js](https://nodejs.org/)
- **Flutter :** Pour faire fonctionner l'application frontend. Consultez la [documentation officielle de Flutter](https://docs.flutter.dev/get-started/install) pour installer la version la plus adaptée à votre système d'exploitation.

## 2. Installation et lancement du Backend

Le backend est un serveur Node.js qui utilise Express et Prisma.

1.  **Cloner le dépôt :**
    Si ce n'est pas déjà fait, clonez le projet sur votre machine.
    ```bash
    git clone <URL_DU_DEPOT>
    cd <NOM_DU_DOSSIER_PROJET>
    ```

2.  **Accéder au dossier backend :**
    Toutes les commandes suivantes doivent être exécutées depuis le dossier `backend`.
    ```bash
    cd backend
    ```

3.  **Installer les dépendances :**
    Installez tous les paquets nécessaires avec npm.
    ```bash
    npm install
    ```

4.  **Configurer la base de données :**
    Le projet utilise Prisma avec une base de données SQLite. Pour initialiser la base de données et générer le client Prisma, exécutez la commande suivante :
    ```bash
    npx prisma migrate dev --name init
    ```
    Cette commande va :
    - Créer le fichier de base de données SQLite `dev.db` dans le dossier `backend/prisma`.
    - Appliquer toutes les migrations existantes pour créer le schéma de la base de données.
    - Générer le client Prisma (`@prisma/client`) pour que votre application puisse interagir avec la base de données.

5.  **Lancer le serveur backend :**
    Une fois la configuration terminée, vous pouvez démarrer le serveur.
    ```bash
    npm start
    ```
    Le serveur devrait maintenant tourner sur `http://localhost:3000`. Vous pouvez le laisser tourner dans un terminal.

## 3. Installation et lancement du Frontend

Le frontend est une application Flutter.

1.  **Accéder au dossier racine du projet :**
    Assurez-vous d'être à la racine du projet (et non plus dans le dossier `backend`).
    ```bash
    cd ..
    ```

2.  **Installer les dépendances Flutter :**
    Téléchargez tous les paquets Dart nécessaires pour l'application.
    ```bash
    flutter pub get
    ```

3.  **Lancer l'application Flutter :**
    Vous pouvez lancer l'application sur l'appareil de votre choix (simulateur iOS, émulateur Android, Chrome pour le web, etc.).
    ```bash
    flutter run
    ```
    Pour choisir un appareil spécifique, utilisez la commande `flutter devices` pour voir la liste des appareils disponibles, puis `flutter run -d <ID_DE_L_APPAREIL>`.

## 4. Vérification

Si tout s'est bien passé :
- Le terminal du backend affichera des logs indiquant que le serveur est en écoute sur le port 3000.
- L'application Flutter se lancera sur votre appareil cible.
- L'application devrait être capable de communiquer avec le backend, vous permettant de voir, créer, et sauvegarder des exercices et des programmes.
