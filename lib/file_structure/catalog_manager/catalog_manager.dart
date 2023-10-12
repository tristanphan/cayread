import 'dart:convert';
import 'dart:io';

import 'package:cayread/book_structures.dart';
import 'package:cayread/file_structure/catalog_manager/book_table_queries.dart';
import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/importer/importer.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:fuzzywuzzy/algorithms/weighted_ratio.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy_lib;
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart' as mime_lib;
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

@lazySingleton
class CatalogManager {
  // Dependencies
  final Logger log = Logger.forType(CatalogManager);
  final FileProvider fileProvider = serviceLocator();
  final ImporterUtils importerUtils = serviceLocator();

  late final SqliteDatabase database;
  static final Finalizer<SqliteDatabase> _finalizer = Finalizer((SqliteDatabase connection) => connection.close());

  /// Sets up the database and the tables
  /// Should be called once at runtime, before any other function runs
  Future<void> initializeDatabase() async {
    File catalogFile = await fileProvider.getCatalogFile();
    database = SqliteDatabase(path: catalogFile.path);
    await database.execute(BookTableQueries.createBookTableQuery);
    _finalizer.attach(this, database);
  }

  /// Imports the book from [file] and adds it the catalog
  /// Returns whether the operation was successful
  Future<bool> importBook(File file) async {
    // Find the importer to use
    String? mimeType = mime_lib.lookupMimeType(file.path);
    if (mimeType == null) return false;
    log.info("Importing file $file with mimetype $mimeType");
    IImporter? importer = importerUtils.getImporter(mimeType);
    log.info("Chose importer ${importer?.importerName}");
    if (importer == null) return false;

    Book book = await importer.import(file);
    await database.execute(BookTableQueries.addBookQuery, [
      book.uuid,
      book.title,
      jsonEncode(book.authors),
      book.type.name,
      book.length,
      book.current,
    ]);
    return true;
  }

  /// Removes the book, along with files, with [uuid] from the catalog
  /// Returns whether the operation was successful
  Future<bool> removeBook(String uuid) async {
    // Check whether the book exists
    Row row = await database.get(BookTableQueries.findIfBookWithUuidExists, [uuid]);
    int count = row.values.whereType<int>().firstOrNull ?? 0;
    if (count == 0) return false;

    // Perform the delete in the catalog
    await database.execute(BookTableQueries.removeBookQuery, [uuid]);

    // Perform the delete in the filesystem
    Directory directory = await fileProvider.getBookDirectory(uuid);
    await directory.delete(recursive: true);
    return true;
  }

  /// Gets a list of books from the catalog
  Future<List<Book>> getBooks() async {
    ResultSet resultSet = await database.getAll(BookTableQueries.getAllBooks);
    List<Book> books = resultSet.map((Row row) {
      return Book(
        uuid: row["uuid"],
        title: row["title"],
        authors: jsonDecode(row["authors"]).whereType<String>().toList(),
        type: BookType.values.firstWhere((BookType bookType) => (bookType.name == row["type"])),
        length: row["length"],
        current: row["current"],
      );
    }).toList();
    return books;
  }

  /// Finds and orders books matching [query]
  Future<List<Book>> findBooks(String query) async {
    if (query.isEmpty) return [];

    List<Book> books = await getBooks();
    List<ExtractedResult<Book>> orderedBooks = fuzzy_lib.extractAllSorted(
      query: query,
      choices: books,
      ratio: const WeightedRatio(),
      getter: (Book book) => "${book.title}; ${book.authors.join("; ")}",
      cutoff: 50,
    );

    return orderedBooks.map((ExtractedResult<Book> extractedResult) => extractedResult.choice).toList();
  }

  /// Closes the catalog database
  /// No other functions should be called after this one runs
  /// Should not be necessary in a Flutter application, but might be in a Dart application
  Future<void> close() async {
    await database.close();
    _finalizer.detach(database);
  }
}
