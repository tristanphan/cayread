import 'dart:convert';

class EpubBook {
  String id;
  ContainerContents containerContents;
  PackageDocumentContents packageDocumentContents;

  EpubBook({
    required this.id,
    required this.containerContents,
    required this.packageDocumentContents,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "containerContents": containerContents.toMap(),
        "packageDocumentContents": packageDocumentContents.toMap(),
      };

  @override
  String toString() => "${(EpubBook).toString()}${jsonEncode(toMap())}";
}

class ContainerContents {
  String packageDocumentPath;
  String packageDocumentType;

  ContainerContents({
    required this.packageDocumentPath,
    required this.packageDocumentType,
  });

  Map<String, dynamic> toMap() => {
        "packageDocumentPath": packageDocumentPath,
        "packageDocumentType": packageDocumentType,
      };

  @override
  String toString() => "${(ContainerContents).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContents {
  PackageDocumentContentsMetadata metadata;
  PackageDocumentContentsManifest manifest;
  PackageDocumentContentsSpine spine;

  PackageDocumentContents({
    required this.metadata,
    required this.manifest,
    required this.spine,
  });

  Map<String, dynamic> toMap() => {
        "metadata": metadata.toMap(),
        "manifest": manifest.toMap(),
        "spine": spine.toMap(),
      };

  @override
  String toString() => "${(PackageDocumentContents).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContentsMetadata {
  String title;
  List<String> creators;

  PackageDocumentContentsMetadata({
    required this.title,
    required this.creators,
  });

  Map<String, dynamic> toMap() => {
        "title": title,
        "creators": creators,
      };

  @override
  String toString() => "${(PackageDocumentContentsMetadata).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContentsManifest {
  Map<String, PackageDocumentContentsManifestItem> items;

  PackageDocumentContentsManifest({
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        "items": items.map((key, value) => MapEntry(key, value.toMap())),
      };

  @override
  String toString() => "${(PackageDocumentContentsManifest).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContentsManifestItem {
  String href;
  String id;
  String mediaType;
  String properties;

  PackageDocumentContentsManifestItem({
    required this.href,
    required this.id,
    required this.mediaType,
    required this.properties,
  });

  Map<String, dynamic> toMap() => {
        "href": href,
        "id": id,
        "media-type": mediaType,
        "properties": properties,
      };

  @override
  String toString() => "${(PackageDocumentContentsManifestItem).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContentsSpine {
  String pageProgressionDirection;
  List<PackageDocumentContentsSpineItem> items;

  PackageDocumentContentsSpine({
    required this.pageProgressionDirection,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        "pageProgressionDirection": pageProgressionDirection,
        "items": items.map((e) => e.toMap()).toList(),
      };

  @override
  String toString() => "${(PackageDocumentContentsSpine).toString()}${jsonEncode(toMap())}";
}

class PackageDocumentContentsSpineItem {
  String idref;
  bool linear;

  PackageDocumentContentsSpineItem({
    required this.idref,
    required this.linear,
  });

  Map<String, dynamic> toMap() => {
        "idref": idref,
        "linear": linear,
      };

  @override
  String toString() => "${(PackageDocumentContentsSpineItem).toString()}${jsonEncode(toMap())}";
}
