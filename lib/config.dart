enum Environment { development, production }

class AppConfig {
  static const Environment currentEnv =
      Environment.development; // Change this to switch

  static String get baseUrl {
    switch (currentEnv) {
      case Environment.production:
        return 'https://api2.batubhayangkara.com';
      case Environment.development:
        return 'http://172.16.2.200:3000';
    }
  }
}
