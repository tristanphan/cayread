import 'dart:io';

import 'package:cayread/injection/injection.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:injectable/injectable.dart';

/// Fetches common directories for the app
@lazySingleton
class FileProvider {
  // Dependencies
  final PathProviderWrapper _pathProviderWrapper = serviceLocator();

  String get _separator => Platform.pathSeparator;

  // The Application Documents Directory is used for all files managed by this app. Not all files
  // stored here are user-generated, but those static files should still be kept here so that relative
  // paths are not broken by an external changes to the directory structure.

  /// Returns the log directory, which stores all .log files created by the logger
  Future<Directory> getLogDirectory() async {
    // $applicationDocuments/logs/
    Directory applicationDocumentsDirectory = await _pathProviderWrapper.getApplicationDocumentsDirectory();
    Directory logDirectory = Directory("${applicationDocumentsDirectory.path}log$_separator");
    await logDirectory.create(recursive: true);
    return logDirectory;
  }
}
