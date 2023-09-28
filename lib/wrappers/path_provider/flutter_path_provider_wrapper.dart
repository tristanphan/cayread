import 'dart:async';
import 'dart:io';

import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class FlutterPathProviderWrapper extends PathProviderWrapper {
  @override
  Future<Directory> getApplicationCacheDirectory() async {
    return _withSeparator(await path_provider.getApplicationCacheDirectory())!;
  }

  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return _withSeparator(await path_provider.getApplicationDocumentsDirectory())!;
  }

  @override
  Future<Directory> getApplicationSupportDirectory() async {
    return _withSeparator(await path_provider.getApplicationSupportDirectory())!;
  }

  @override
  Future<Directory?> getDownloadsDirectory() async {
    return _withSeparator(await path_provider.getDownloadsDirectory());
  }

  @override
  Future<List<Directory>?> getExternalCacheDirectories() async {
    return (await path_provider.getExternalCacheDirectories())
        ?.map((Directory directory) => _withSeparator(directory)!)
        .toList();
  }

  Future<List<Directory>?> getExternalStorageDirectories({path_provider.StorageDirectory? type}) async {
    return (await path_provider.getExternalStorageDirectories(type: type))
        ?.map((Directory directory) => _withSeparator(directory)!)
        .toList();
  }

  @override
  Future<Directory?> getExternalStorageDirectory() async {
    return _withSeparator(await path_provider.getExternalStorageDirectory());
  }

  @override
  Future<Directory> getLibraryDirectory() async {
    return _withSeparator(await path_provider.getLibraryDirectory())!;
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return _withSeparator(await path_provider.getTemporaryDirectory())!;
  }

  Directory? _withSeparator(Directory? directory) {
    if (directory == null) return null;
    if (directory.path.endsWith(Platform.pathSeparator)) return directory;
    return Directory("${directory.path}${Platform.pathSeparator}");
  }
}
