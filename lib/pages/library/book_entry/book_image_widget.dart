import 'package:cayread/book_structures.dart';
import 'package:flutter/material.dart';

class BookImageWidget extends StatelessWidget {
  final DisplayableBook displayableBook;
  final double imageSize;

  const BookImageWidget({
    super.key,
    required this.displayableBook,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 10 / 16,
          child: Image.file(
            displayableBook.coverImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _BookImageMissingWidget(book: displayableBook),
          ),
        ),
      ),
    );
  }
}

class _BookImageMissingWidget extends StatelessWidget {
  final Book book;

  const _BookImageMissingWidget({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              color: theme.colorScheme.background,
              size: 40,
            ),
            Text(
              book.type.name.toUpperCase(),
              style: TextStyle(color: theme.colorScheme.background, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
