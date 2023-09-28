/// Wrapper for the path_provider module, useful for dependency injection and mocking
/// Abstractness is to separate behavior from dependency on Flutter
abstract class RootBundle {
  Future<String> loadString(String assetName, {bool cache = true});
}
