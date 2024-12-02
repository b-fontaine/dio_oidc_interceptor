import 'package:injectable/injectable.dart';

import 'configuration.dart';

@prod
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationDev implements Configuration {
  @override
  String get apiBaseUrl => "https://connect.domain.com/";

  @override
  String get authClientId => "";

  @override
  String get authClientSecret => "";

  @override
  String get authTokenUrl => "";
}
