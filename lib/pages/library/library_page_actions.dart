import 'dart:io';

import 'package:cayread/book_structures.dart';
import 'package:cayread/file_structure/catalog_manager/catalog_manager.dart';
import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/importer/importer.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:share_plus/share_plus.dart';

/// Actions associated with the Library Page
class LibraryPageActions {
  // Dependencies
  final CatalogManager _catalogManager = serviceLocator();
  final FileProvider _fileProvider = serviceLocator();
  final IPathProviderWrapper _pathProviderWrapper = serviceLocator();

  final BuildContext _context;

  // Callbacks
  final void Function(VoidCallback) _setState;
  final void Function() _refreshLibrary;
  final void Function() _incrementLoading;
  final void Function() _decrementLoading;

  LibraryPageActions({
    required BuildContext context,
    required Function(void Function()) setState,
    required Function() refreshLibrary,
    required Function() incrementLoading,
    required Function() decrementLoading,
  })  : _context = context,
        _setState = setState,
        _incrementLoading = _wrap(incrementLoading),
        _decrementLoading = _wrap(decrementLoading),
        _refreshLibrary = _wrap(refreshLibrary);

  /// Returns a future list of [DisplayableBook]
  Future<List<DisplayableBook>> getDisplayableBooks() async {
    // Set loading status
    _setState(_incrementLoading);

    // Get list of books and their image file paths
    List<Book> books = await _catalogManager.getBooks();
    Iterable<Future<DisplayableBook>> displayableBooksFuture = books.map((Book book) async {
      File coverImage = await _fileProvider.getBookCoverImageFile(book.uuid);
      return DisplayableBook(book: book, coverImage: coverImage);
    });
    List<DisplayableBook> displayableBooks = await Future.wait(displayableBooksFuture);

    // Stop loading status
    _setState(_decrementLoading);
    return displayableBooks;
  }

  /// Opens the file picker and imports the selected book
  /// Will set the [_isLoading] flag to true while the book is being imported
  Future<void> importBookAction() async {
    // Set loading status
    _setState(_incrementLoading);

    // Prompt the user and import the file
    File? file = await _getFileFromPicker();
    if (file != null) {
      bool success = await _catalogManager.importBook(file);
      if (success) {
        _refreshLibrary();
      } else {
        SnackBar snackBar = SnackBar(
          content: const Text("Failed to importing the book."),
          action: SnackBarAction(
            label: "Try Again",
            onPressed: importBookAction,
          ),
        );
        if (_context.mounted) ScaffoldMessenger.of(_context).showSnackBar(snackBar);
      }
    }

    // Stop loading status
    _setState(_decrementLoading);
  }

  /// Deletes the book with the [uuid] and refreshes the catalog
  Future<void> removeBookAction(String uuid) async {
    await _catalogManager.removeBook(uuid);
    _setState(_refreshLibrary);
  }

  /// Copies the file of the book under [uuid] of type [type] to the temporary directory and shares it
  Future<void> saveBookAction(Book book) async {
    File originalFile = await _fileProvider.getOriginalFilePath(
      book.uuid,
      book.type,
    );
    String extension = path_lib.extension(originalFile.uri.path);
    Directory tempDir = await _pathProviderWrapper.getTemporaryDirectory();
    File targetFile = File("${tempDir.path}${book.title}.$extension");
    await originalFile.copy(targetFile.path);
    await Share.shareXFiles([XFile(targetFile.path)]);
    await targetFile.delete();
  }

  /// Opens the file picker, allowing the [allowedExtensions], and returns the selected file
  Future<File?> _getFileFromPicker({allowedExtensions = ImporterUtils.supportedExtensions}) async {
    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );
    String? path = selectedFile?.files.firstOrNull?.path;
    return path == null ? null : File(path);
  }
}

/// Wraps the [function] such that it will return nothing
/// This is necessary since [_setState] should accept a void function
void Function() _wrap(Function() function) {
  return () {
    function();
  };
}
