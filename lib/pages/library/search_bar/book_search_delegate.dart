import 'package:cayread/book_structures.dart';
import 'package:cayread/file_structure/catalog_manager/catalog_manager.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/pages/library/book_list_widget.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:flutter/material.dart';

class BookSearchDelegate extends SearchDelegate {
  // Dependencies
  final CatalogManager catalogManager = serviceLocator();

  // Fields
  final BuildContext context;

  // Variables
  late final LibraryPageActions _libraryPageActions;
  late Future<List<DisplayableBook>> suggestions;

  BookSearchDelegate(this.context, {String hintText = "Search"})
      : super(
          searchFieldLabel: hintText,
          searchFieldStyle: Theme.of(context).textTheme.bodyLarge,
        ) {
    _libraryPageActions = LibraryPageActions(
      context: context,
      setState: (void Function() fn) {},
      refreshLibrary: () => suggestions = _libraryPageActions.getDisplayableBooks(catalogManager.findBooks(query)),
      incrementLoading: () {},
      decrementLoading: () {},
    );
    _libraryPageActions.refreshLibrary();
  }

  /// Builds the clear button when there is text in the search bar
  @override
  List<Widget>? buildActions(BuildContext context) {
    Padding clearButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.clear_rounded),
      ),
    );
    return [if (query != "") clearButton];
  }

  /// Builds the back button
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_ios_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _libraryPageActions.refreshLibrary();
    return FutureBuilder(
      future: suggestions,
      builder: (BuildContext context, AsyncSnapshot<List<DisplayableBook>> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        List<DisplayableBook> books = snapshot.data!;

        return Column(
          children: [
            if (books.isEmpty) _NoResultsWidget(query: query),
            if (books.isNotEmpty)
              BookListWidget(books: books, libraryPageActions: _libraryPageActions.copyWith(setState: setState)),
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  void setState(void Function() fn) {
    fn();
    // Reload search page
    query = query;
  }
}

/// Displays the row tooltip for when there are no results
class _NoResultsWidget extends StatelessWidget {
  final String query;

  const _NoResultsWidget({required this.query});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.manage_search)),
            const Padding(padding: EdgeInsets.only(left: 12.0)),
            Expanded(
              child: Text(
                (query.isEmpty) ? "Type something to begin searching" : "No results for \"$query\"",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
