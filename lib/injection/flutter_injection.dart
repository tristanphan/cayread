import 'package:cayread/injection/injection.dart';
import 'package:cayread/wrappers/path_provider/flutter_path_provider_wrapper.dart';
import 'package:cayread/wrappers/path_provider/path_provider_wrapper.dart';
import 'package:cayread/wrappers/root_bundle/flutter_root_bundle.dart';
import 'package:cayread/wrappers/root_bundle/root_bundle.dart';

void registerFlutterWrappers() {
  serviceLocator.registerLazySingleton<PathProviderWrapper>(() => FlutterPathProviderWrapper());
  serviceLocator.registerLazySingleton<RootBundle>(() => FlutterRootBundle());
}
