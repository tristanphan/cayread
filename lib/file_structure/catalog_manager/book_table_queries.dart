class BookTableQueries {
  static const String createBookTableQuery = """
      CREATE TABLE IF NOT EXISTS Books (
          uuid    UUID    PRIMARY KEY     NOT NULL,
          title   TEXT                    NOT NULL,
          authors TEXT,
          type    TEXT CHECK(type in ('epub', 'pdf')),

          -- reading progress
          length  INTEGER                 NOT NULL,
          current INTEGER     DEFAULT 1   NOT NULL
      );
  """;

  static const String addBookQuery = """
      INSERT INTO Books
      (uuid, title, authors, type, length, current)
      VALUES
      (?, ?, ?, ?, ?, ?);
  """;

  static const String removeBookQuery = """
      DELETE FROM Books
      WHERE uuid = ?;
  """;

  static const String getAllBooks = """
      SELECT * FROM Books;
  """;

  static const String findIfBookWithUuidExists = """
      SELECT COUNT(*) FROM BOOKS
      WHERE uuid = ?;
  """;
}
