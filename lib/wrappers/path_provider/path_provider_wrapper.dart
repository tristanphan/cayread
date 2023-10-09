import 'dart:async';
import 'dart:io';

/// Wrapper for the path_provider module, useful for dependency injection and mocking
/// Abstractness is to separate behavior from dependency on Flutter
/// Also enforces that all directory paths must end with a separator

// @lazySingleton ~ Proper implementation should be registered separately
// depending on the runner since it may have dependencies on Flutter
abstract class IPathProviderWrapper {
  Future<Directory> getApplicationCacheDirectory();

  Future<Directory> getApplicationDocumentsDirectory();

  Future<Directory> getApplicationSupportDirectory();

  Future<Directory?> getDownloadsDirectory();

  Future<List<Directory>?> getExternalCacheDirectories();

  Future<Directory?> getExternalStorageDirectory();

  Future<Directory> getLibraryDirectory();

  Future<Directory> getTemporaryDirectory();
}
