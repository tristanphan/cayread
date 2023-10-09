/// Wrapper for the root_bundle module, useful for dependency injection and mocking
/// Abstractness is to separate behavior from dependency on Flutter
abstract class IRootBundle {
  Future<String> loadString(String assetName, {bool cache = true});
}
