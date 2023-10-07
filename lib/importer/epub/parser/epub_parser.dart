import 'dart:io';

import 'package:cayread/importer/epub/parser/epub_constants.dart';
import 'package:cayread/importer/epub/parser/epub_structures.dart';
import 'package:cayread/importer/epub/epub_file_provider.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// Parses an extracted Epub file's metadata (from temporary directory) into an [EpubBook] object.
@lazySingleton
class EpubParser {
  EpubParser(this.bookId);

  // Dependencies
  final Logger _log = Logger.forType(EpubFileProvider);
  final EpubFileProvider _epubFileManager = serviceLocator();

  // Parameters
  final String bookId;

  Future<EpubBook> parseEpub() async {
    ContainerContents containerContents = await _parseContainer();
    // NOTE: ignoring signatures.xml
    // NOTE: ignoring encryption.xml
    // NOTE: ignoring metadata.xml
    // NOTE: ignoring manifest.xml
    PackageDocumentContents packageDocumentContents =
        await _parsePackageDocument(containerContents.packageDocumentPath);

    return EpubBook(
      id: bookId,
      containerContents: containerContents,
      packageDocumentContents: packageDocumentContents,
    );
  }

  Future<ContainerContents> _parseContainer() async {
    // Setup
    final File containerFile = await _epubFileManager.getContainerFile(bookId);
    final XmlDocument containerDocument = XmlDocument.parse(await containerFile.readAsString());

    // Parsing
    XmlElement? containerRootFileNode =
        containerDocument.xpath(EpubConstants.containerDocumentRootFile).whereType<XmlElement>().firstOrNull;
    String? packageDocumentPath =
        containerRootFileNode?.getAttribute(EpubConstants.containerDocumentFullPathAttribute)?.trim();
    String? packageDocumentType =
        containerRootFileNode?.getAttribute(EpubConstants.containerDocumentMediaTypeAttribute)?.trim();
    _log.assertThat(packageDocumentPath != null, errorMessage: "Could not find container.xml file path");
    _log.assertThat(packageDocumentType?.toLowerCase() == EpubConstants.oebpsPackageMimeType,
        errorMessage: "Incorrect package document type: $packageDocumentType");

    // Processing
    packageDocumentPath = (await _epubFileManager.getContentDirectory(bookId)).path + packageDocumentPath!;

    // Collecting
    final ContainerContents contents = ContainerContents(
      packageDocumentPath: packageDocumentPath,
      packageDocumentType: packageDocumentType!,
    );
    _log.info("Found container contents: $contents");
    return contents;
  }

  Future<PackageDocumentContents> _parsePackageDocument(String packageDocumentPath) async {
    // Setup
    final File packageFile = File(packageDocumentPath);
    final XmlDocument packageDocument = XmlDocument.parse(await packageFile.readAsString());

    // Parsing
    final PackageDocumentContentsMetadata metadata = await _parsePackageDocumentMetadata(packageDocument);
    final PackageDocumentContentsManifest manifest = await _parsePackageDocumentManifest(packageDocument);
    final PackageDocumentContentsSpine spine = await _parsePackageDocumentSpine(packageDocument);

    // Cross-checking
    for (var item in spine.items) {
      String idref = item.idref;
      _log.assertThat(manifest.items.containsKey(idref), errorMessage: "Spine itemref not found in manifest: $idref");
    }

    // Collecting
    PackageDocumentContents contents = PackageDocumentContents(
      metadata: metadata,
      manifest: manifest,
      spine: spine,
    );
    _log.info("Found package document contents: $contents");
    return contents;
  }

  Future<PackageDocumentContentsMetadata> _parsePackageDocumentMetadata(XmlDocument xmlDocument) async {
    // Parsing
    String? title = xmlDocument
        .xpath(EpubConstants.packageDocumentMetadataTitleXPath)
        .whereType<XmlElement>()
        .firstOrNull
        ?.innerText
        .trim();
    List<String> creators = xmlDocument
        .xpath(EpubConstants.packageDocumentMetadataCreatorXPath)
        .whereType<XmlElement>()
        .map<String>((XmlElement element) => element.innerText.trim())
        .toList();
    // NOTE: ignoring dc:identifier
    // NOTE: ignoring dc:language
    // NOTE: ignoring <meta> elements
    // NOTE: ignoring <link> elements
    // NOTE: ignoring dir property because it can apply to many elements
    _log.assertThat(title != null, errorMessage: "Title is null");

    // Collecting
    final PackageDocumentContentsMetadata metadata = PackageDocumentContentsMetadata(
      title: title!,
      creators: creators,
    );
    _log.info("Found package document content (metadata): $metadata");
    return metadata;
  }

  Future<PackageDocumentContentsManifest> _parsePackageDocumentManifest(XmlDocument xmlDocument) async {
    // Parsing
    Iterable<XmlElement> itemElements =
        xmlDocument.xpath(EpubConstants.packageDocumentManifestItemXPath).whereType<XmlElement>();
    Map<String, PackageDocumentContentsManifestItem> items = {};
    for (XmlElement node in itemElements) {
      String? id = node.getAttribute(EpubConstants.packageDocumentManifestItemIdAttribute)?.trim();
      String? href = node.getAttribute(EpubConstants.packageDocumentManifestItemHrefAttribute)?.trim();
      String? mediaType = node.getAttribute(EpubConstants.packageDocumentManifestItemMediaTypeAttribute)?.trim();
      String properties = node.getAttribute(EpubConstants.packageDocumentManifestItemPropertiesAttribute)?.trim() ?? "";
      _log.assertThat(id != null,
          errorMessage: "Manifest item ${EpubConstants.packageDocumentManifestItemIdAttribute} is null");
      _log.assertThat(href != null,
          errorMessage: "Manifest item ${EpubConstants.packageDocumentManifestItemHrefAttribute} is null");
      _log.assertThat(mediaType != null,
          errorMessage: "Manifest item ${EpubConstants.packageDocumentManifestItemMediaTypeAttribute} is null");
      // NOTE: ignoring fallback attribute
      // NOTE: ignoring media-overlay attribute

      items[id!] = PackageDocumentContentsManifestItem(
        id: id,
        href: href!,
        mediaType: mediaType!,
        properties: properties,
      );
    }

    // Collecting
    final PackageDocumentContentsManifest manifest = PackageDocumentContentsManifest(
      items: items,
    );
    _log.info("Found package document content (manifest): $manifest");
    return manifest;
  }

  Future<PackageDocumentContentsSpine> _parsePackageDocumentSpine(XmlDocument xmlDocument) async {
    // Parsing
    String pageProgressionDirection = xmlDocument
            .xpath(EpubConstants.packageDocumentSpineItemrefXPath)
            .whereType<XmlElement>()
            .firstOrNull
            ?.getAttribute(EpubConstants.packageDocumentSpinePageProgressionDirectionAttribute)
            ?.trim() ??
        "";

    Iterable<XmlElement> itemrefElements =
        xmlDocument.xpath(EpubConstants.packageDocumentSpineItemrefXPath).whereType<XmlElement>();
    List<PackageDocumentContentsSpineItem> items = [];
    for (XmlElement node in itemrefElements) {
      String? idref = node.getAttribute(EpubConstants.packageDocumentSpineItemrefIdrefAttribute)?.trim();
      bool linear = node.getAttribute(EpubConstants.packageDocumentSpineItemrefLinearAttribute)?.trim() != "no";
      _log.assertThat(idref != null, errorMessage: "Spine itemref ID is null");
      // NOTE: ignoring id attribute
      // NOTE: ignoring properties attribute
      items.add(PackageDocumentContentsSpineItem(
        idref: idref!,
        linear: linear,
      ));
    }

    // Collecting
    final PackageDocumentContentsSpine spine = PackageDocumentContentsSpine(
      pageProgressionDirection: pageProgressionDirection,
      items: items,
    );
    _log.info("Found package document content (spine): $spine");
    return spine;
  }
}
