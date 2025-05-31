import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Search books by query
  static Future<List<Book>> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return [];
        }

        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  // Get book details by ID (optional for future use)
  static Future<Book?> getBookById(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
