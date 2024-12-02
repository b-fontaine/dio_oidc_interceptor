import 'package:injectable/injectable.dart';

import 'configuration.dart';

@test
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationDev implements Configuration {
  @override
  String get apiBaseUrl => "https://test-connect/";

  @override
  String get authClientId => "test-client-id";

  @override
  String get authClientSecret => "test-client-secret";

  @override
  String get authTokenUrl => "https://test-connect/oauth/token";
}
