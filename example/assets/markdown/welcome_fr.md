# Bienvenue

Vous apprendrez ici à utiliser l'intercepteur OIDC pour Dio.

## Qu'est-ce que l'OIDC ?

L'OpenID Connect (OIDC) est un protocole d'authentification basé sur le protocole OAuth 2.0, conçu pour permettre aux applications de vérifier l'identité d'un utilisateur de manière sécurisée et d'obtenir des informations de profil utilisateur de base (comme le nom ou l'email) via un serveur d'autorisation. OIDC ajoute une couche d'identité à OAuth 2.0, qui se concentre uniquement sur l'autorisation, en fournissant un mécanisme standardisé pour gérer l'authentification.

OIDC repose sur des JSON Web Tokens (JWT) comme format pour transmettre les données d'authentification entre les parties, garantissant une structure compacte, sécurisée, et facile à vérifier. Il définit plusieurs flux d'authentification (ou "flows"), comme le *Authorization Code Flow*, le *Implicit Flow*, et le *Hybrid Flow*, adaptés à différents scénarios d'utilisation.

### Utilité de l'OIDC

1. **Authentification centralisée** : OIDC permet de centraliser l'authentification des utilisateurs via un fournisseur d'identité (Identity Provider ou IdP). Cela simplifie l'accès aux applications multiples tout en offrant une meilleure expérience utilisateur (par exemple, un SSO ou Single Sign-On).

2. **Sécurité renforcée** : Grâce à l'usage des JWT et de normes comme HTTPS, OIDC garantit que les données échangées sont authentiques et qu'elles n'ont pas été altérées ou interceptées par des tiers malveillants.

3. **Réduction des responsabilités côté client** : En déléguant l'authentification à un fournisseur d'identité, les applications clientes (ou *relying parties*) n'ont pas à gérer directement des informations sensibles comme les mots de passe, ce qui réduit le risque de failles de sécurité.

4. **Interopérabilité** : En tant que standard ouvert, OIDC est compatible avec de nombreux services et plateformes. Cela permet aux développeurs d'intégrer facilement des fonctionnalités d'authentification avec des fournisseurs populaires comme Google, Microsoft, ou Okta.

5. **Accessibilité des données utilisateur** : En plus de l'authentification, OIDC permet aux applications de récupérer des informations supplémentaires sur l'utilisateur grâce à des "claims" incluses dans le token, comme l'adresse email, le prénom ou des informations de rôle, pour personnaliser l'expérience utilisateur.

Pour résumer, OIDC combine l'efficacité d'OAuth 2.0 pour la gestion des autorisations avec une couche d'identité robuste, répondant aux besoins modernes de sécurité et de convivialité dans les systèmes distribués.

## Utilisation de l'intercepteur OIDC pour Dio

Pour utiliser l'intercepteur OIDC avec Dio, vous devez suivre les étapes suivantes :

### Ajouter les dépendances nécessaires
 
Assurez-vous d'avoir les dépendances Dio et, en option, Retrofit installées dans votre projet Flutter.
Ajoutez le package `dio_oidc_interceptor` à votre fichier `pubspec.yaml` en exécutant la commande suivante :

```shell
flutter pub add dio_oidc_interceptor
```

### Configurer l'intercepteur OIDC

Créez une instance de `OidcInterceptor` en spécifiant la configuration OIDC requise, comme le `clientId`, le `clientSecret`, l'URI du fournisseur OIDC, et les scopes nécessaires. Ajoutez cet intercepteur à votre client Dio.

```dart
import 'package:dio/dio.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';

void main() async {
  final dio = Dio();
  final interceptor = OidcInterceptor(
        configuration: OpenIdConfiguration(
      clientId: 'your-client-id',
      clientSecret: 'your-client-secret',
      uri: 'https://your-oidc-provider.com',
      scopes: ['openid', 'profile', 'email'],
    ));
  dio.interceptors.add(interceptor);
  
  await dio.login();
  final response = await dio.get('https://api.example.com');
}
```

### Utiliser l'intercepteur avec Retrofit

Si vous utilisez Retrofit pour gérer vos appels réseau, vous pouvez également intégrer l'intercepteur OIDC dans vos interfaces de service.

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'backend_client.g.dart';

@RestApi(baseUrl: 'https://website/api/version/')
abstract class BackendClient {
  factory BackendClient(Dio dio, {String baseUrl}) = _BackendClient;
}

class Backend {
  late final Dio _dio;
  late final BackendClient _backendClient;
  final interceptor = OidcInterceptor(
      configuration: OpenIdConfiguration(
        clientId: 'your-client-id',
        clientSecret: 'your-client-secret',
        uri: 'https://your-oidc-provider.com',
        scopes: ['openid', 'profile', 'email'],
      ));

  Backend(Authentication auth, Configuration configuration) {
    _dio = Dio()..interceptors.add(interceptor);
    _backendClient = BackendClient(_dio, baseUrl: 'https://website/api/version/');
  }

  Dio get dio => _dio;
  BackendClient get backendClient => _backendClient;
}
```

### Utiliser le starter kit Listo pour Flutter

Vous pouvez utiliser le Starter Kit Listo pour Flutter pour démarrer rapidement un projet avec une Clean Archi, l'injection de dépendances configurée ainsi que de quoi piloter vos développements par les tests Gherkin.

Pour ça, vous pouvez créer un fork du projet [Listo Starter Kit](https://github.com/Listo-Paye/listo_starter_kit) et suivre les instructions du README pour démarrer votre projet.

Ensuite, il vous suffira de suivre l'exemple de cette application pour intégrer l'intercepteur OIDC à votre projet.
