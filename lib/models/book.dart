class Book {
  final String id;
  final String title;
  final String author;
  final String? imageUrl;
  final String? description;
  final String? publishedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    this.description,
    this.publishedDate,
  });

  // Factory constructor to create a Book from Google Books API JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final authors = volumeInfo['authors'] as List<dynamic>?;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      author: authors?.isNotEmpty == true ? authors!.join(', ') : 'Unknown Author',
      imageUrl: imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail'],
      description: volumeInfo['description'],
      publishedDate: volumeInfo['publishedDate'],
    );
  }

  // Convert Book to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'description': description,
      'publishedDate': publishedDate,
    };
  }

  // Factory constructor to create a Book from SQLite Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      author: map['author'] ?? 'Unknown Author',
      imageUrl: map['imageUrl'],
      description: map['description'],
      publishedDate: map['publishedDate'],
    );
  }

  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
