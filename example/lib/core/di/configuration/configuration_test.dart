import 'package:injectable/injectable.dart';

import 'configuration.dart';

@test
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationDev implements Configuration {
  @override
  String get apiBaseUrl => "";
}