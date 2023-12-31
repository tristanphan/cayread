import 'package:cayread/book_structures.dart';
import 'package:cayread/file_structure/catalog_manager/catalog_manager.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/pages/library/book_list_widget.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:cayread/pages/library/search_bar/search_bar_widget.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Dependencies
  final CatalogManager _catalogManager = serviceLocator();

  // Number of tasks currently processing
  int _loadingCount = 0;
  late Future<List<DisplayableBook>> _booksFuture;
  late final LibraryPageActions _libraryPageActions;

  @override
  void initState() {
    _libraryPageActions = LibraryPageActions(
      context: context,
      setState: setState,
      incrementLoading: () => _loadingCount++,
      decrementLoading: () => _loadingCount--,
      refreshLibrary: () => _booksFuture = _libraryPageActions.getDisplayableBooks(_catalogManager.getBooks()),
    );
    _libraryPageActions.refreshLibrary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColorfulSafeArea(
        overflowRules: const OverflowRules.all(true),
        color: Colors.white.withOpacity(0.4),
        child: ListView(children: [
          SearchBarWidget(
            isLoading: _loadingCount > 0,
            libraryPageActions: _libraryPageActions,
          ),
          FutureBuilder(
            future: _booksFuture,
            builder: (BuildContext context, AsyncSnapshot<List<DisplayableBook>> snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text("An error occurred."));

              List<DisplayableBook> books = snapshot.data!;
              return BookListWidget(
                books: books,
                libraryPageActions: _libraryPageActions,
              );
            },
          ),
        ]),
      ),
    );
  }
}
