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

  // .../$uuid/to_extract.zip
  Future<String> getZipFilePath(String uuid) async {
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    String zipPath = "${bookDir.path}to_extract.zip";
    log.info("Zip path: $zipPath");
    return zipPath;
  }

  // .../$uuid/original.epub
  Future<String> getOriginalEpubFilePath(String uuid) async {
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    String epubPath = "${bookDir.path}original.epub";
    log.info("Epub path: $epubPath");
    return epubPath;
  }

  // .../$uuid/contents/
  Future<Directory> getContentDirectory(String uuid) async {
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    Directory contentDir = Directory("${bookDir.path}contents$separator");
    log.info("Contents directory: ${contentDir.path}");
    return contentDir;
  }

  // .../$uuid/contents/META-INF/container.xml
  Future<File> getContainerFile(String uuid) async {
    Directory contentDir = await getContentDirectory(uuid);
    File containerPath = File("${contentDir.path}META-INF${separator}container.xml");
    log.info("Container file path: $containerPath");
    return containerPath;
  }

  // .../$uuid/index.html
  Future<File> getIndexFile(String uuid) async {
    Directory bookDir = await fileProvider.getBookDirectory(uuid);
    File indexFile = File("${bookDir.path}index.html");
    log.info("Index file: ${indexFile.path}");
    await indexFile.create(recursive: true);
    return indexFile;
  }
}
