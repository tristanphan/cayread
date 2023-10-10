import 'package:cayread/book_structures.dart';
import 'package:cayread/pages/library/library_actions.dart';
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: books.length,
      itemBuilder: (BuildContext context, int index) {
        DisplayableBook displayableBook = books[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${displayableBook.title}"),
            Text("Authors: ${displayableBook.authors.join("; ")}"),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
            ),
          ],
        );
      },
    );
  }
}
