import 'dart:convert';
import 'dart:io';

class Book {
  String uuid;
  String title;
  List<String> authors;
  BookType type;
  int length;
  int current;

  Book({
    required this.uuid,
    required this.title,
    required this.authors,
    required this.type,
    required this.length,
    this.current = 1,
  });

  Book copy() {
    return Book(
      uuid: uuid,
      title: title,
      authors: authors,
      type: type,
      length: length,
      current: current,
    );
  }

  Map<String, dynamic> toMap() => {
        "uuid": uuid,
        "title": title,
        "authors": authors,
        "type": type,
        "length": length,
        "current": current,
      };

  @override
  String toString() => "${(Book).toString()}${jsonEncode(toMap())}";
}

// An extension of [Book] that supports [coverImage]
class DisplayableBook extends Book {
  File coverImage;

  DisplayableBook({required Book book, required this.coverImage})
      : super(
          uuid: book.uuid,
          title: book.title,
          authors: book.authors,
          type: book.type,
          length: book.length,
          current: book.current,
        );
}

enum BookType {
  epub,
  pdf,
  ;

  String toJson() => name;
}
