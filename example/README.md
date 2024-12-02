# [EN] Dio OIDC Interceptor

This project is derived from the [Listo Paye Flutter Starter Kit](https://github.com/Listo-Paye/flutter_starter_kit).

For more details, refer to the [Medium article "Clean and Modular Architecture with Flutter: From Structure to Gherkin Tests"](https://medium.com/@benotfontaine/architecture-clean-et-modulaire-avec-flutter-de-la-structure-aux-tests-gherkin-879a37c0c2a5).

--------

## How to Run This Example Locally?

### Prerequisites

First, you need a Flutter-compatible IDE:
* [Android Studio](https://developer.android.com/studio)
* [Visual Studio Code](https://code.visualstudio.com/)
* [IntelliJ IDEA](https://www.jetbrains.com/idea/)

Next, you need the Flutter tools:
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* [Git](https://git-scm.com/)
* [Android SDK](https://developer.android.com/studio#downloads)
* [Xcode](https://developer.apple.com/xcode/)
* [CocoaPods](https://cocoapods.org/)
* [JDK 17](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html)
* [Chrome](https://www.google.com/chrome/)

Finally, you need Docker and Docker Compose:
* [Docker](https://docs.docker.com/get-docker/)

### Running the Example

First, you need to install and start Keycloak. Run the following command from this directory:
```bash
docker-compose -p oidc up -d
```

You can verify the installation is working correctly by accessing the following URL: [http://localhost:8080/](http://localhost:8080/)
* Username: `admin`
* Password: `admin`

Next, download the dependencies:
```bash
flutter pub get
```

Run the build_runner:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Finally, you can start the application:
```bash
flutter run -d chrome -t lib/main_dev.dart
```

Of course, it is possible to run it on another device depending on your configuration. This example is designed to run on:
- Web
- Android
- iOS / iPadOS
- macOS
- Linux
- Windows

# [FR] Dio OIDC Interceptor

Ce projet est issu du [Starter Kit Flutter de Listo Paye](https://github.com/Listo-Paye/flutter_starter_kit). 

Pour plus d'informations, je vous renvoie vers [l'article Medium "Architecture Clean et Modulaire avec Flutter : De la Structure aux Tests Gherkin"](https://medium.com/@benotfontaine/architecture-clean-et-modulaire-avec-flutter-de-la-structure-aux-tests-gherkin-879a37c0c2a5)

--------

## Comment lancer en local cet exemple ?

### Pré-requis
Tout d'abord, il vous faut un IDE compatible Flutter
* [Android Studio](https://developer.android.com/studio)
* [Visual Studio Code](https://code.visualstudio.com/)
* [IntelliJ IDEA](https://www.jetbrains.com/idea/)

Ensuite, il vous faut les outils Flutter
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Dart SDK](https://dart.dev/get-dart)
* [Git](https://git-scm.com/)
* [Android SDK](https://developer.android.com/studio#downloads)
* [Xcode](https://developer.apple.com/xcode/)
* [CocoaPods](https://cocoapods.org/)
* [JDK 17](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html)
* [Chrome](https://www.google.com/chrome/)

Enfin, il vous faut Docker et Docker Compose
* [Docker](https://docs.docker.com/get-docker/)

### Lancer l'exemple

Avant toute chose, vous devez installer Keycloak et le lancer. Pour cela, exécutez la commande suivante depuis ce répertoire :
```bash
docker-compose -p oidc up -d
```

Vous pouvez tester que l'installation fonctionne bien en allant sur l'URL suivante : [http://localhost:8080/](http://localhost:8080/)
* Identifiant : `admin`
* Mot de passe : `admin`

Ensuite, vous devez télécharger les dépendances
```bash
flutter pub get
```

et lancer le build_runner
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Enfin, vous pouvez lancer l'application
```bash
flutter run -d chrome -t lib/main_dev.dart
```

Il est bien sûr possible de le lancer sur un autre device selon votre configuration. Cet exemple est prévu pour être lancé sur :
- Web
- Android
- iOS / padOS
- MacOS
- Linux
- Windows
