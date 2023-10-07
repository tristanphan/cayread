import 'package:cayread/injection/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

final GetIt serviceLocator = GetIt.instance;

@injectableInit
void configureDependencies() {
  serviceLocator.init();
}

@module
abstract class RegisterModule {
  @lazySingleton
  Uuid get uuid => const Uuid();
}
