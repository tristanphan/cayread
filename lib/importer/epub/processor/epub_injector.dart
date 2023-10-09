import 'dart:io';

import 'package:cayread/file_structure/asset_manager.dart';
import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/importer/epub/epub_file_provider.dart';
import 'package:cayread/importer/epub/parser/epub_structures.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path_lib;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

@lazySingleton
class EpubInjector {
  // Dependencies
  final Logger log = Logger.forType(EpubInjector);
  final AssetManager assetManager = serviceLocator();
  final EpubFileProvider epubFileProvider = serviceLocator();
  final FileProvider fileProvider = serviceLocator();

  /// Adds location number attributes to the body of the [document], starting from the [startLocation]
  /// Returns the next location number to be used on subsequent calls
  int injectLocationNumbering(XmlDocument document, int startLocation) {
    log.info("Injecting location numbering");
    int nextLocation = startLocation;
    for (XmlElement element in getBodyElement(document).descendantElements) {
      // Check if the element directly contains text OR has no children
      XmlElement elementWithoutChildren = element.copy();
      elementWithoutChildren.children.removeWhere((element) => element.nodeType == XmlNodeType.ELEMENT);

      if (elementWithoutChildren.innerText.trim().isNotEmpty || element.childElements.isEmpty) {
        element.attributes.add(XmlAttribute(XmlName("data-ereader__location"), nextLocation.toString()));
        nextLocation++;
      }
    }
    document.rootElement.attributes
        .add(XmlAttribute(XmlName("data-ereader__location_start"), startLocation.toString()));
    document.rootElement.attributes.add(XmlAttribute(XmlName("data-ereader__location_end"), (nextLocation).toString()));
    return nextLocation;
  }

  /// Add injection script to the beginning of the head of the [document]
  Future<void> injectScript(XmlDocument document, File file) async {
    log.info("Injecting script");
    String relativeScriptPath = path_lib.relative(
      (await assetManager.getAssetFile(Asset.epubInjectScript)).path,
      from: file.parent.absolute.path,
    );
    XmlElement scriptElement = XmlElement(XmlName("script"), [
      XmlAttribute(XmlName("src"), relativeScriptPath),
    ]);

    getHeadElement(document).children.insert(0, scriptElement);
  }

  /// Add injection stylesheet to the beginning of the head of the [document]
  Future<void> injectStyle(XmlDocument document, File file) async {
    log.info("Injecting style");
    String relativeStylePath = path_lib.relative(
      (await assetManager.getAssetFile(Asset.epubInjectStyle)).path,
      from: file.parent.absolute.path,
    );
    XmlElement scriptElement = XmlElement(XmlName("link"), [
      XmlAttribute(XmlName("rel"), "stylesheet"),
      XmlAttribute(XmlName("href"), relativeStylePath),
    ]);

    getHeadElement(document).children.insert(0, scriptElement);
  }

  /// Inject the path to the previous and next file stylesheet to the [document]
  void injectPreviousAndNext(XmlDocument document, File current, File? previous, File? next) {
    if (previous != null) {
      log.info("Injecting previous");
      String relativePreviousPath = path_lib.relative(previous.absolute.path, from: current.parent.absolute.path);
      document.rootElement.attributes.add(XmlAttribute(XmlName("data-ereader__previous"), relativePreviousPath));
    }
    if (next != null) {
      log.info("Injecting next");
      String relativeNextPath = path_lib.relative(next.absolute.path, from: current.parent.absolute.path);
      document.rootElement.attributes.add(XmlAttribute(XmlName("data-ereader__next"), relativeNextPath));
    }
  }

  /// Inject the path to the index file stylesheet to the [document]
  Future<void> injectIndex(XmlDocument document, File current, EpubBook book) async {
    File indexFile = await epubFileProvider.getIndexFile(book.id);
    String relativeIndexFile = path_lib.relative(indexFile.path, from: current.parent.absolute.path);
    document.rootElement.attributes.add(XmlAttribute(XmlName("data-ereader__index"), relativeIndexFile));
  }

  /// Returns the <body> element of the [document]
  XmlElement getBodyElement(XmlDocument document) {
    XmlElement? bodyElement = document.rootElement.xpath("/html/body").whereType<XmlElement>().firstOrNull;
    log.assertThat(bodyElement != null, errorMessage: "Could not find body element");
    return bodyElement!;
  }

  /// Returns the <head> element of the [document]
  XmlElement getHeadElement(XmlDocument document) {
    XmlElement? headElement = document.rootElement.xpath("/html/head").whereType<XmlElement>().firstOrNull;
    log.assertThat(headElement != null, errorMessage: "Could not find head element");
    return headElement!;
  }
}
