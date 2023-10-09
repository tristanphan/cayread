import 'package:cayread/wrappers/root_bundle/root_bundle.dart';
import 'package:flutter/services.dart';

class FlutterRootBundle implements IRootBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return rootBundle.loadString(key, cache: cache);
  }
}
