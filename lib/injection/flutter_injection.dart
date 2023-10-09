import 'package:cayread/injection/injection.dart';
import 'package:cayread/wrappers/path_provider/flutter_path_provider_wrapper.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:cayread/wrappers/root_bundle/flutter_root_bundle.dart';
import 'package:cayread/wrappers/root_bundle/root_bundle.dart';

/// These dependencies require Flutter packages, so stubbed or alternative
/// implementations are required for testing or usage in plain Dart
void registerFlutterWrappers() {
  serviceLocator.registerLazySingleton<IPathProviderWrapper>(() => FlutterPathProviderWrapper());
  serviceLocator.registerLazySingleton<IRootBundle>(() => FlutterRootBundle());
}
