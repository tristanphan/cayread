import 'dart:io';

import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:injectable/injectable.dart';

// Provides common points of interest for the EPUB structure
@lazySingleton
class EpubFileProvider {
  // Dependencies
  final Logger log = Logger.forType(EpubFileProvider);
  final FileProvider fileProvider = serviceLocator();

  String get separator => Platform.pathSeparator;

  /// Returns the path to the pre-extracted EPUB file as a ZIP file of the book under [uuid]
  /// This file should be deleted after extracting
  Future<String> getZipFilePath(String uuid) async {
    // .../$uuid/to_extract.zip
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    String zipPath = "${bookDir.path}to_extract.zip";
    log.info("Zip path: $zipPath");
    return zipPath;
  }

  /// Returns the path to the EPUB file of the book under [uuid]
  /// This file is kept in case the user wants it back, or in case we need to recreate the book
  Future<String> getOriginalEpubFilePath(String uuid) async {
    // .../$uuid/original.epub
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    String epubPath = "${bookDir.path}original.epub";
    log.info("Epub path: $epubPath");
    return epubPath;
  }

  /// Returns the path to the directory containing the extracted EPUB contents of the book under [uuid]
  Future<Directory> getContentDirectory(String uuid) async {
    // .../$uuid/contents/
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    Directory contentDir = Directory("${bookDir.path}contents$separator");
    log.info("Contents directory: ${contentDir.path}");
    return contentDir;
  }

  /// Returns the path to the container.xml file of the book under [uuid]
  Future<File> getContainerFile(String uuid) async {
    // .../$uuid/contents/META-INF/container.xml
    Directory contentDir = await getContentDirectory(uuid);
    File containerPath = File("${contentDir.path}META-INF${separator}container.xml");
    log.info("Container file path: $containerPath");
    return containerPath;
  }

  /// Returns the path to the index.html file of the book under [uuid]
  Future<File> getIndexFile(String uuid) async {
    // .../$uuid/index.html
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    File indexFile = File("${bookDir.path}index.html");
    log.info("Index file: ${indexFile.path}");
    await indexFile.create(recursive: true);
    return indexFile;
  }
}
