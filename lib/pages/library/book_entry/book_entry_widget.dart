import 'package:cayread/book_structures.dart';
import 'package:cayread/common_widgets/modal_bottom_sheet/modal_bottom_sheet_structures.dart';
import 'package:cayread/pages/library/book_entry/book_image_widget.dart';
import 'package:cayread/pages/library/library_page_actions.dart';
import 'package:cayread/common_widgets/modal_bottom_sheet/modal_bottom_sheet.dart';
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

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ModalBottomSheet(
          header: ModalBottomSheetHeader(
            image: displayableBook.coverImage,
            icon: const Icon(Icons.menu_book),
            title: Text(displayableBook.title),
            subtitle: Text(displayableBook.authors.join("; ")),
          ),
          actions: [
            ModalBottomSheetAction(
              icon: const Icon(Icons.cloud_download),
              text: const Text("Save Original File"),
              onPressed: () {
                if (context.mounted) Navigator.pop(context);
                libraryPageActions.saveBookAction(displayableBook);
              },
            ),
            ModalBottomSheetAction(
              icon: const Icon(Icons.delete),
              text: const Text("Delete"),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, true);
                _openDeleteConfirmationMenu(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _openDeleteConfirmationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ModalBottomSheet(
          header: ModalBottomSheetHeader(
            icon: const Icon(Icons.delete_forever),
            title: const Text("Delete Book?"),
            subtitle: Text(displayableBook.title),
          ),
          actions: [
            ModalBottomSheetAction(
              icon: const Icon(Icons.delete),
              text: const Text("Delete"),
              isDestructiveAction: true,
              onPressed: () {
                libraryPageActions.removeBookAction(displayableBook.uuid);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ModalBottomSheetAction(
              icon: const Icon(Icons.close),
              text: const Text("Cancel"),
              onPressed: () {
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openReader(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(children: [
          const Padding(padding: EdgeInsets.only(right: 16)),
          BookImageWidget(displayableBook: displayableBook, imageSize: 80),
          const Padding(padding: EdgeInsets.only(right: 10)),
          Expanded(child: _EntryText(displayableBook: displayableBook)),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _openMenu(context)),
        ]),
      ),
    );
  }
}

class _EntryText extends StatelessWidget {
  final DisplayableBook displayableBook;

  const _EntryText({required this.displayableBook});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
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
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
