import 'package:cayread/file_structure/asset_manager.dart';
import 'package:cayread/file_structure/catalog_manager/catalog_manager.dart';
import 'package:cayread/injection/flutter_injection.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/pages/library/library_page.dart';
import 'package:flutter/material.dart';

void main() async {
  registerFlutterWrappers();
  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await serviceLocator<CatalogManager>().initializeDatabase();
  await serviceLocator<AssetManager>().initializeAssets();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cayread",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LibraryPage(),
    );
  }
}
