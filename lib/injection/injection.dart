import 'package:cayread/injection/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

final GetIt serviceLocator = GetIt.instance;

@injectableInit
void configureDependencies() {
  serviceLocator.init();
}

/// Third-party dependencies can be registered here
@module
abstract class ThirdPartyDependenciesModule {
  @lazySingleton
  Uuid get uuid => const Uuid();
}
