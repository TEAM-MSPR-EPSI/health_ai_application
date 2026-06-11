# health_ai_application

Application mobile Flutter de healthAI.

## Vue d'ensemble

L'application gère un flux social, la création de publications avec média, la consultation du profil et la mise à jour des informations utilisateur. Le point d'entrée initialise la configuration API avant de charger l'interface principale.

## Fonctionnalités

- Flux d'actualité avec rafraîchissement manuel
- Publication de texte, photo ou vidéo
- Visualisation des propres publications
- Modification du profil principal
- Changement de photo de profil ou d'avatar emoji
- Authentification avec redirection automatique selon l'état de session

## Stack Flutter

- Flutter + Dart
- GetX pour l'état et la navigation
- image_picker pour la sélection de médias
- video_player pour la lecture vidéo
- shared_preferences pour mémoriser la base API
- HTTP pour les appels REST

## Structure utile

- lib/main.dart : démarrage de l'application et initialisation API
- lib/app.dart : racine de l'application et AuthGate
- lib/pages/ : écrans principaux
- lib/controllers/ : logique d'état
- lib/services/ : accès API et configuration
- lib/widgets/ : composants réutilisables
- lib/theme/ : thème visuel

## Prérequis

- Flutter SDK installé
- Android Studio, VS Code ou un IDE Flutter compatible
- Un émulateur ou un appareil connecté
- Le backend healthAI-backend-API lancé sur le port 5000

## Installation et lancement

1. Se placer dans le dossier health_ai_application
2. Exécuter flutter pub get
3. Vérifier l'environnement avec flutter doctor
4. Lancer l'application avec flutter run

### Base API

La configuration API utilise une base différente selon la plateforme :
- Android emulator : http://10.0.2.2:5000
- iPhone / Android physique sur hotspot Windows : http://192.168.137.1:5000
- iOS / desktop / web : http://localhost:5000

Si besoin, tu peux aussi surcharger l'URL au démarrage avec l'argument Dart API_BASE_URL.

Sur téléphone physique, `localhost` et `10.0.2.2` ne pointent pas vers le PC. Si tu utilises le hotspot Windows, le backend doit répondre sur l'IP passerelle du PC, généralement `192.168.137.1`.

## Tests et maintenance

- flutter test : lance les tests widget
- flutter clean : nettoie le projet si l'environnement Flutter est incohérent
- flutter pub get : régénère les dépendances après un changement de pubspec

## Bug récurrent

### Impossible de lancer le projet ou message No modules selected dans la configuration Dart

Ce problème apparaît souvent quand Android Studio conserve une configuration .idea corrompue. La résolution la plus fiable est de supprimer le dossier .idea, puis de rouvrir le projet dans Android Studio et de relancer flutter pub get.

Si le problème persiste, relance flutter doctor et vérifie aussi que le SDK Flutter est bien sélectionné dans l'IDE.

## Références Flutter

- Documentation officielle : https://docs.flutter.dev/
- Guide des commandes : https://docs.flutter.dev/reference/flutter-cli