import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cayread/book_structures.dart';
import 'package:cayread/importer/epub/parser/epub_structures.dart';
import 'package:cayread/importer/epub/epub_file_provider.dart';
import 'package:cayread/importer/epub/parser/epub_parser.dart';
import 'package:cayread/importer/epub/processor/epub_processor.dart';
import 'package:cayread/importer/importer.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

// Manages the importing of an EPUB file into the library
@lazySingleton
class EpubImporter implements IImporter {
  // Dependencies
  final Logger _log = Logger.forType(EpubImporter);
  final Uuid _uuid = serviceLocator();
  final EpubFileProvider _epubFileProvider = serviceLocator();
  final EpubProcessor _epubProcessor = serviceLocator();

  /// Extracts [sourceFile] (EPUB file) into a temp directory, processes it, and returns the [Book] object
  @override
  Future<Book> import(File sourceFile) async {
    _log.assertThat(await sourceFile.exists(), errorMessage: "Source file does not exist: ${sourceFile.absolute.path}");
    _log.info("Importing epub file: ${sourceFile.absolute.path}");

    // Extract
    final String bookId = _uuid.v4();
    _log.info("Using ID: $bookId");
    await sourceFile.copy(await _epubFileProvider.getOriginalEpubFilePath(bookId));
    final File zipFile = await sourceFile.copy(await _epubFileProvider.getZipFilePath(bookId));
    await extractFileToDisk(zipFile.path, (await _epubFileProvider.getContentDirectory(bookId)).path);
    unawaited(zipFile.delete());

    // Parse & Process EPUB
    EpubBook epubBook = await EpubParser(bookId).parseEpub();
    int length = await _epubProcessor.processXHtmlSpineItems(epubBook);
    await _epubProcessor.processCoverImage(epubBook);

    Book book = Book(
      uuid: bookId,
      title: epubBook.packageDocumentContents.metadata.title,
      authors: epubBook.packageDocumentContents.metadata.creators,
      type: BookType.epub,
      length: length,
    );

    return book;
  }

  @override
  String get importerName => (EpubImporter).toString();
}
