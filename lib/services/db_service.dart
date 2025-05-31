import '../models/book.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // In-memory storage for favorites (works on all platforms)
  final List<Book> _favorites = [];

  // Insert a book into favorites
  Future<void> insertItem(Book book) async {
    // Remove if already exists to avoid duplicates
    _favorites.removeWhere((b) => b.id == book.id);
    _favorites.add(book);
  }

  // Get all favorite books
  Future<List<Book>> getItems() async {
    return List.from(_favorites);
  }

  // Delete a book from favorites
  Future<void> deleteItem(String id) async {
    _favorites.removeWhere((book) => book.id == id);
  }

  // Check if a book is in favorites
  Future<bool> isFavorite(String id) async {
    return _favorites.any((book) => book.id == id);
  }

  // Clear all favorites (optional utility method)
  Future<void> clearAllFavorites() async {
    _favorites.clear();
  }

  // Close the database (no-op for in-memory storage)
  Future<void> close() async {
    // No-op for in-memory storage
  }
}
