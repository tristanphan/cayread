import 'dart:io';

import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:cayread/wrappers/root_bundle/root_bundle.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AssetManager {
  // Dependencies
  final Logger log = Logger.forType(AssetManager);
  final IPathProviderWrapper pathProviderWrapper = serviceLocator();
  final IRootBundle rootBundle = serviceLocator();

  String get separator => Platform.pathSeparator;

  /// $applicationDocuments/assets/$asset
  Future<File> getAssetFile(Asset asset) async {
    Directory applicationDocumentsDirectory = await pathProviderWrapper.getApplicationDocumentsDirectory();
    File assetFile = File("${applicationDocumentsDirectory.path}assets$separator${asset.path}");
    log.info("Asset file: ${assetFile.absolute.path}");
    return assetFile;
  }

  /// Copies all assets to the application documents directory
  Future<void> initializeAssets() async {
    for (Asset asset in Asset.values) {
      File assetFile = await getAssetFile(asset);
      await assetFile.create(recursive: true);
      await assetFile.writeAsString(await rootBundle.loadString(asset.assetName));
    }
  }
}

enum Asset {
  epubIndexScript(path: "index_script.js", assetName: "assets/index_script.js"),
  epubInjectScript(path: "inject_script.js", assetName: "assets/inject_script.js"),
  epubInjectStyle(path: "inject_style.css", assetName: "assets/inject_style.css"),
  ;

  // The path is relative from the assets/ directory
  final String path;
  final String assetName;

  const Asset({
    required this.path,
    required this.assetName,
  });

  String toJson() => assetName;
}
