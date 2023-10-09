import 'dart:io';

import 'package:cayread/file_structure/asset_manager.dart';
import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/importer/epub/epub_file_provider.dart';
import 'package:cayread/importer/epub/parser/epub_constants.dart';
import 'package:cayread/importer/epub/parser/epub_structures.dart';
import 'package:cayread/importer/epub/processor/epub_injector.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:image/image.dart' as image_lib;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path_lib;
import 'package:xml/xml.dart';

@lazySingleton
class EpubProcessor {
  // Dependencies
  final Logger _log = Logger.forType(EpubProcessor);
  final AssetManager _assetManager = serviceLocator();
  final EpubFileProvider _epubFileProvider = serviceLocator();
  final EpubInjector _injector = serviceLocator();
  final FileProvider _fileProvider = serviceLocator();

  /// Identifies the cover image of the [book], converts it, and copies it to the book directory
  Future<void> processCoverImage(EpubBook book) async {
    // This parent file path prefix is necessary since the hrefs in the manifest are relative to the package document
    String manifestItemParent = File(book.containerContents.packageDocumentPath).parent.path;
    if (!manifestItemParent.endsWith("/")) manifestItemParent += "/";

    PackageDocumentContentsManifestItem? coverItem = book.packageDocumentContents.manifest.items.entries
        .where((MapEntry<String, PackageDocumentContentsManifestItem> element) =>
            element.value.properties.split(" ").contains("cover-image"))
        .firstOrNull
        ?.value;

    _log.assertThat(coverItem != null, errorMessage: "Cover not found in manifest");
    _log.assertThat(_supportedImageMimeTypes.contains(coverItem?.mediaType.toLowerCase()),
        errorMessage: "Cover has unsupported mimetype ${coverItem?.mediaType}");
    File cover = File("$manifestItemParent${coverItem?.href}");
    await _copyAsPng(book, cover);
  }

  /// Converts the [file] from a type in [_supportedImageMimeTypes] to PNG in the book directory
  Future<void> _copyAsPng(EpubBook book, File file) async {
    image_lib.Image? image = image_lib.decodeImage(await file.readAsBytes());
    _log.assertThat(image != null, errorMessage: "Unable to copy or convert image");
    image_lib.Image smallerImage = image_lib.copyResize(image!, width: 800);
    File target = await _fileProvider.getBookCoverImageFile(book.id);
    await target.writeAsBytes(image_lib.encodePng(smallerImage, level: 8));
  }

  /// Modifies each XHtml spine item to inject the script, style, location numbering, and create the index file
  /// Returns the length, which is the last location number (inclusive)
  Future<int> processXHtmlSpineItems(EpubBook book) async {
    // This parent file path prefix is necessary since the hrefs in the manifest are relative to the package document
    String manifestItemParent = File(book.containerContents.packageDocumentPath).parent.path;
    if (!manifestItemParent.endsWith("/")) manifestItemParent += "/";

    Iterable<File> chapterFiles = book.packageDocumentContents.spine.items
        .map((spineItem) => book.packageDocumentContents.manifest.items[spineItem.idref])
        .nonNulls
        .where((manifestItem) => manifestItem.mediaType.toLowerCase() == EpubConstants.xHtmlMimeType)
        .map((manifestItem) => File("$manifestItemParent${manifestItem.href}"));

    int startLocation = 1;
    List<_ChapterLocation> chapterLocations = []; // index = chapter number, value = [start inclusive, end exclusive]

    for (var (index, file) in chapterFiles.indexed) {
      _log.info("Processing item: ${file.absolute.path}");
      XmlDocument document = XmlDocument.parse(file.readAsStringSync());

      // Processing: Location Number
      int endLocation = _injector.injectLocationNumbering(document, startLocation);
      _log.info("Added chapter #${index + 1} in range [$startLocation, $endLocation)");
      chapterLocations.add(_ChapterLocation(file.path, startLocation, endLocation));
      startLocation = endLocation;

      // Processing: DOM Injection
      await _injector.injectScript(document, file);
      await _injector.injectStyle(document, file);

      // Processing: Chapter Linking
      File? previous = index == 0 ? null : chapterFiles.elementAtOrNull(index - 1);
      File? next = chapterFiles.elementAtOrNull(index + 1);
      _injector.injectPreviousAndNext(document, file, previous, next);

      await _injector.injectIndex(document, file, book);

      await file.writeAsString(document.toXmlString(pretty: true));
    }

    await _makeIndexFile(book, chapterLocations);
    return startLocation - 1;
  }

  Future<void> _makeIndexFile(EpubBook book, List<_ChapterLocation> chapterLocations) async {
    File indexFile = await _epubFileProvider.getIndexFile(book.id);

    String relativeScriptPath = path_lib.relative(
      (await _assetManager.getAssetFile(Asset.epubIndexScript)).path,
      from: indexFile.parent.absolute.path,
    );

    XmlBuilder builder = XmlBuilder();
    builder.declaration(encoding: "UTF-8");
    builder.doctype("html");
    builder.element("html", attributes: {
      "xmlns": "http://www.w3.org/1999/xhtml",
    }, nest: () {
      for (_ChapterLocation chapter in chapterLocations) {
        String relativeChapterPath = path_lib.relative(chapter.path, from: indexFile.parent.absolute.path);

        builder.element("div",
            attributes: {
              "data-ereader__path": relativeChapterPath,
              "data-ereader__start": chapter.startLocation.toString(),
              "data-ereader__end": chapter.endLocation.toString(),
            },
            isSelfClosing: false);
      }

      builder.element("script", attributes: {"src": relativeScriptPath}, isSelfClosing: false);
    });
    await indexFile.writeAsString(builder.buildDocument().toXmlString(pretty: true));
    _log.info("Index file: ${indexFile.absolute.path}");
  }
}

class _ChapterLocation {
  final String path;
  final int startLocation;
  final int endLocation;

  _ChapterLocation(this.path, this.startLocation, this.endLocation);
}

// These are the image types that can be rendered by the Image widget
List<String> _supportedImageMimeTypes = [
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
  "image/bmp",
];
