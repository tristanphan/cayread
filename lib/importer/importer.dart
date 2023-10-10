import 'dart:io';

import 'package:cayread/book_structures.dart';
import 'package:cayread/importer/epub/epub_importer.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:injectable/injectable.dart';

abstract class IImporter {
  Future<Book> import(File sourceFile);

  String get importerName;
}

@lazySingleton
class ImporterUtils {
  final Logger log = Logger.forType(ImporterUtils);

  /// Gets a file importer from [mimeType] if there exists an [IImporter] for that type
  IImporter? getImporter(String mimeType) {
    log.info("Finding importer for $mimeType");
    IImporter Function()? importerGetter = _mimeTypes[mimeType];
    if (importerGetter != null) return importerGetter();
    log.info("No importer found for mimetype $mimeType");
    return null;
  }

  /// Maps mimetypes to a function that returns an [IImporter] instance for that type
  static final Map<String, IImporter Function()> _mimeTypes = {
    "application/epub+zip": () => serviceLocator<EpubImporter>(),
  };

  static const List<String> supportedExtensions = [
    "epub",
  ];
}
