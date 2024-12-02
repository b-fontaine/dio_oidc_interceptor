import 'package:injectable/injectable.dart';

import 'configuration.dart';

@dev
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationDev implements Configuration {
  @override
  String get apiBaseUrl => "http://localhost:8080/";

  @override
  String get authClientId => "example-cli";

  @override
  String get authClientSecret => "bozic9kGF1BEMjPXGHtxy8xyU3rDAfSJ";

  @override
  String get authTokenUrl => "http://localhost:8080/realms/master";
}
