import 'dart:io';

import 'package:cayread/injection/injection.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:injectable/injectable.dart';

/// Fetches common directories for the app
@lazySingleton
class FileProvider {
  // Dependencies
  final IPathProviderWrapper _pathProviderWrapper = serviceLocator();

  String get _separator => Platform.pathSeparator;

  // The Application Documents Directory is used for all files managed by this app. Not all files
  // stored here are user-generated, but those static files should still be kept here so that relative
  // paths are not broken by an external changes to the directory structure.

  /// Returns the library directory, which stores all books
  Future<Directory> getLibraryDirectory() async {
    // $applicationDocuments/library/
    Directory applicationDocumentsDirectory = await _pathProviderWrapper.getApplicationDocumentsDirectory();
    Directory libraryDirectory = Directory("${applicationDocumentsDirectory.path}library$_separator");
    await libraryDirectory.create(recursive: true);
    return libraryDirectory;
  }

  /// Returns the directory to the catalog.db file, which stores the book catalog
  Future<File> getCatalogFile() async {
    // $applicationDocuments/catalog.db
    Directory applicationDocumentsDirectory = await _pathProviderWrapper.getApplicationDocumentsDirectory();
    File catalogFile = File("${applicationDocumentsDirectory.path}catalog.db");
    await catalogFile.create(recursive: true);
    return catalogFile;
  }

  /// Returns the log directory, which stores all .log files created by the logger
  Future<Directory> getLogDirectory() async {
    // $applicationDocuments/logs/
    Directory applicationDocumentsDirectory = await _pathProviderWrapper.getApplicationDocumentsDirectory();
    Directory logDirectory = Directory("${applicationDocumentsDirectory.path}log$_separator");
    await logDirectory.create(recursive: true);
    return logDirectory;
  }

  /// Returns the book directory of the book identified by [uuid], which is inside the library directory
  Future<Directory> getBookDirectory(String uuid) async {
    // $library/$uuid/
    Directory libraryDirectory = await getLibraryDirectory();
    Directory bookDir = Directory("${libraryDirectory.path}$uuid$_separator");
    await bookDir.create(recursive: true);
    return bookDir;
  }

  /// Returns the cover image of the book identified by [uuid], which is inside the book directory
  Future<File> getBookCoverImageFile(String uuid) async {
    // $library/$uuid/cover.png
    return File("${(await getBookDirectory(uuid)).path}cover.png");
  }
}
