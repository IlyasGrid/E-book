import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const EbookApp());
}

class EbookApp extends StatelessWidget {
  const EbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ebook Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.deepPurple[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 6,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.deepPurple[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.deepPurple[300]),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.deepPurpleAccent,
          elevation: 12,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.deepPurple[400],
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const BookLibraryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Book {
  final String title;
  final String author;
  final String description;
  final String? thumbnailUrl;

  Book({
    required this.title,
    required this.author,
    required this.description,
    this.thumbnailUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final authors = volumeInfo['authors'] as List<dynamic>?;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    return Book(
      title: volumeInfo['title']?.toString() ?? 'Unknown Title',
      author:
          authors?.isNotEmpty == true
              ? authors!.first.toString()
              : 'Unknown Author',
      description:
          volumeInfo['description']?.toString() ?? 'No description available',
      thumbnailUrl:
          imageLinks != null ? imageLinks['thumbnail'] as String? : null,
    );
  }
}

class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({super.key});

  @override
  State<BookLibraryScreen> createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  final List<Book> _favorites = [];
  List<Book> _dashboardBooks = [];
  bool _isLoading = false;
  bool _isDashboardLoading = true;
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        // Set dark theme
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
      }
    });
  }

  void _suggestRandomBook() {
    final allBooks = [..._dashboardBooks, ..._books];
    if (allBooks.isNotEmpty) {
      final randomBook = (allBooks..shuffle()).first;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                randomBook.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (randomBook.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          randomBook.thumbnailUrl!,
                          height: 120,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'by ${randomBook.author}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      randomBook.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No books to suggest!')));
    }
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _books = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=10',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>?;
        setState(() {
          if (items != null) {
            _books = items.map((item) => Book.fromJson(item)).toList();
          } else {
            _books = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _books = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _books = [];
        _isLoading = false;
      });
      print('Error searching books: $e');
    }
  }

  void _toggleFavorite(Book book) {
    setState(() {
      final isAlreadyFavorite = _favorites.any(
        (fav) => fav.title == book.title,
      );
      if (isAlreadyFavorite) {
        _favorites.removeWhere((fav) => fav.title == book.title);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${book.title} removed from favorites')),
        );
      } else {
        _favorites.add(book);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${book.title} added to favorites')),
        );
      }
    });
  }

  bool _isFavorite(Book book) {
    return _favorites.any((fav) => fav.title == book.title);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          _isDarkMode
              ? ThemeData.dark().copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: Colors.grey[900],
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                ),
                cardTheme: CardTheme(
                  color: Colors.grey[850],
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.deepPurpleAccent,
                  unselectedItemColor: Colors.white70,
                ),
              )
              : Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ebook Library'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Suggest a Book',
              onPressed: _suggestRandomBook,
            ),
          ],
        ),
        body: _selectedIndex == 0 ? _buildSearchTab() : _buildFavoritesTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
        floatingActionButton:
            _selectedIndex == 0
                ? FloatingActionButton.extended(
                  onPressed: _suggestRandomBook,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Suggest Book'),
                )
                : null,
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for books...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _books = [];
                          });
                        },
                      )
                      : null,
            ),
            onSubmitted: _searchBooks,
            onChanged: (value) {
              setState(() {}); // Update UI for clear button
            },
          ),
          const SizedBox(height: 20),

          // Dashboard Books or Search Results
          Expanded(
            child: _books.isEmpty ? _buildDashboard() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_isDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Books',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              _dashboardBooks.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load featured books',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'Check your internet connection',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _dashboardBooks.length,
                    itemBuilder: (context, index) {
                      final book = _dashboardBooks[index];
                      final isFav = _isFavorite(book);
                      return Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child:
                                    book.thumbnailUrl != null
                                        ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            book.thumbnailUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.book,
                                                      size: 40,
                                                      color: Colors.blue,
                                                    ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.book,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleFavorite(book),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFav
                                                    ? Colors.red
                                                    : Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        final isFav = _isFavorite(book);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading:
                book.thumbnailUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.thumbnailUrl!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.book, color: Colors.blue),
                      ),
                    )
                    : Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.book, color: Colors.blue),
                    ),
            title: Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('by ${book.author}'),
                const SizedBox(height: 4),
                Text(
                  book.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(book),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite books yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add books to favorites from the search tab',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Favorites (${_favorites.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final book = _favorites[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          book.thumbnailUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Icon(Icons.book, color: Colors.red),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('by ${book.author}'),
                        const SizedBox(height: 4),
                        Text(
                          book.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _toggleFavorite(book),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
