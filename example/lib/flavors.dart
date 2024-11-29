enum Flavor {
  prod,
  dev,
  test,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.prod:
        return 'Production';
      case Flavor.dev:
        return 'Dev';
      default:
        return 'Test';
    }
  }
}
