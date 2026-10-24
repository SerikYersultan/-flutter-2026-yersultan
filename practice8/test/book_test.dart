import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('Seed contains 1220 pages and four unread books', () {
    expect(seed.length, 5);
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
  });

  test('Missing year stays null and missing read defaults to false', () {
    final book = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});

    expect(book.year, isNull);
    expect(book.read, isFalse);
    expect(book.toString(), 'X — Y, 10 pp.');
  });

  test('fromMap reads an explicit year and read flag', () {
    final book = Book.fromMap({
      'title': 'Example',
      'author': 'Author',
      'pages': 20,
      'year': 2022,
      'read': true,
    });

    expect(book.year, 2022);
    expect(book.read, isTrue);
  });

  test('toString includes a known year', () {
    expect(
      seed[1].toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
  });

  test('Authors are unique and preserve their original order', () {
    final books = [
      Book(title: 'First', author: 'A', pages: 10),
      Book(title: 'Second', author: 'B', pages: 20),
      Book(title: 'Third', author: 'A', pages: 30),
    ];

    expect(authors(books), ['A', 'B']);
  });

  test('Collection functions handle an empty list', () {
    expect(totalPages([]), 0);
    expect(unread([]), isEmpty);
    expect(authors([]), isEmpty);
  });
}
