class EpubConstants {
  static const String oebpsPackageMimeType = "application/oebps-package+xml";
  static const String xHtmlMimeType = "application/xhtml+xml";

  static const String containerDocumentRootFile = "/container/rootfiles/rootfile";
  static const String containerDocumentFullPathAttribute = "full-path";
  static const String containerDocumentMediaTypeAttribute = "media-type";

  static const String packageDocumentMetadataTitleXPath = "/package/metadata/dc:title";
  static const String packageDocumentMetadataCreatorXPath = "/package/metadata/dc:creator";

  static const String packageDocumentManifestItemXPath = "/package/manifest/item";
  static const String packageDocumentManifestItemHrefAttribute = "href";
  static const String packageDocumentManifestItemMediaTypeAttribute = "media-type";
  static const String packageDocumentManifestItemIdAttribute = "id";
  static const String packageDocumentManifestItemPropertiesAttribute = "properties";

  static const String packageDocumentSpineXPath = "/package/spine";
  static const String packageDocumentSpinePageProgressionDirectionAttribute = "page-progression-direction";
  static const String packageDocumentSpineItemrefXPath = "/package/spine/itemref";
  static const String packageDocumentSpineItemrefIdrefAttribute = "idref";
  static const String packageDocumentSpineItemrefLinearAttribute = "linear";
}
