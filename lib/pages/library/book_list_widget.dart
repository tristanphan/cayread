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
    if (books.isEmpty) return const _BookListEmptyWidget();
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
  const _BookListEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Text("No books yet");
  }
}
