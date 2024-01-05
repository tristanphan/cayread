import 'package:cayread/book_structures.dart';
import 'package:cayread/pages/library/book_entry/book_entry_widget.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:flutter/material.dart';

class BookListWidget extends StatelessWidget {
  final List<DisplayableBook> books;
  final LibraryPageActions libraryPageActions;

  const BookListWidget({
    super.key,
    required this.books,
    required this.libraryPageActions,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return _BookListEmptyWidget(
        libraryPageActions: libraryPageActions,
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: books.length,
      itemBuilder: (BuildContext context, int index) {
        DisplayableBook displayableBook = books[index];
        return BookEntryWidget(
          displayableBook: displayableBook,
          libraryPageActions: libraryPageActions,
        );
      },
    );
  }
}

class _BookListEmptyWidget extends StatelessWidget {
  final LibraryPageActions libraryPageActions;

  const _BookListEmptyWidget({required this.libraryPageActions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.auto_stories,
              size: 48,
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          Text(
            "Your library is empty",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 24)),
          ElevatedButton.icon(
            onPressed: libraryPageActions.importBookAction,
            icon: const Icon(Icons.add),
            label: const Text("Get Started"),
          ),
        ],
      ),
    );
  }
}
