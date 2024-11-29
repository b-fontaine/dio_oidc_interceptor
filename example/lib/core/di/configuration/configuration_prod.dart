import 'package:injectable/injectable.dart';

import 'configuration.dart';

@prod
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationDev implements Configuration {
  @override
  String get apiBaseUrl => "";
}