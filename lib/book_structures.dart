import 'dart:convert';

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

enum BookType {
  epub,
  pdf,
  ;

  String toJson() => name;
}
