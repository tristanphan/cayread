import 'package:cayread/book_structures.dart';
import 'package:cayread/pages/library/book_entry/book_image_widget.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:flutter/material.dart';

class BookEntryWidget extends StatelessWidget {
  final DisplayableBook displayableBook;
  final LibraryPageActions libraryPageActions;

  const BookEntryWidget({
    super.key,
    required this.displayableBook,
    required this.libraryPageActions,
  });

  void _openReader(BuildContext context) {
    // TODO open reader
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () => _openReader(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(children: [
          const Padding(padding: EdgeInsets.only(right: 16)),
          BookImageWidget(
            displayableBook: displayableBook,
            imageSize: 80,
          ),
          const Padding(padding: EdgeInsets.only(right: 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayableBook.title,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  displayableBook.authors.join("; "),
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
