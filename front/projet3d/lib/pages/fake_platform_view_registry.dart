// Fake pour les plateformes non-web
class FakePlatformViewRegistry {
  void registerViewFactory(String viewTypeId, dynamic Function(int) viewFactory) {
    throw UnsupportedError("platformViewRegistry is not supported on this platform.");
  }
}

final platformViewRegistry = FakePlatformViewRegistry();

