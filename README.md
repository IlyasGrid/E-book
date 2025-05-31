# Book Library - Professional Flutter Mobile Application

A modern, professional Flutter mobile application for searching and managing favorite books using the Google Books API and local storage. Features a beautiful dashboard-style interface with Material Design 3.

## Features

- **📚 Professional Dashboard**: Modern dashboard-style interface with statistics cards
- **🔍 Advanced Search**: Search for books using the Google Books API with enhanced UI
- **📖 Grid Layout**: Beautiful grid layout for displaying books with cover images
- **❤️ Smart Favorites**: Add and remove books from favorites with visual feedback
- **💾 Local Storage**: Store favorite books locally with in-memory database
- **🎨 Modern UI**: Professional design with gradients, shadows, and Material Design 3
- **📱 Responsive Design**: Works perfectly on mobile, tablet, and web platforms
- **🧭 Tab Navigation**: Organized content with tabs and bottom navigation

## Technical Requirements

### Dependencies

- `http: ^1.1.0` - For API calls to Google Books API
- `sqflite: ^2.3.0` - For local SQLite database storage
- `path: ^1.8.3` - For database path management

### API Used

- **Google Books API**: `https://www.googleapis.com/books/v1/volumes?q=flutter`
  - Parameter `q` is the search query keyword

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── book.dart            # Book data model
├── services/
│   ├── api_service.dart     # Google Books API service
│   └── db_service.dart      # SQLite database service
└── screens/
    ├── home_screen.dart     # Main search screen
    └── favorites_screen.dart # Favorites management screen
```

## Implementation Details

### 1. Book Model (`lib/models/book.dart`)

- Defines the Book class with properties: id, title, author, imageUrl, description, publishedDate
- Includes factory constructors for JSON parsing and SQLite mapping
- Implements `fromJson()` for API response parsing
- Implements `toMap()` and `fromMap()` for database operations

### 2. Database Service (`lib/services/db_service.dart`)

Implements the required database functions:

- `insertItem(Book book)` - Add a book to favorites
- `getItems()` - Retrieve all favorite books
- `deleteItem(String id)` - Remove a book from favorites
- Additional utility methods for checking favorites and database management

### 3. API Service (`lib/services/api_service.dart`)

- `searchBooks(String query)` - Search books using Google Books API
- Handles HTTP requests and JSON response parsing
- Error handling for network issues

### 4. User Interface

#### Home Screen (`lib/screens/home_screen.dart`)

- Search bar for entering book queries
- FutureBuilder for asynchronous API calls
- ListView displaying search results
- Favorite button for each book (filled/empty based on status)
- Navigation to favorites screen

#### Favorites Screen (`lib/screens/favorites_screen.dart`)

- ListView/GridView displaying saved favorite books
- Delete functionality for removing books
- Book details dialog
- Clear all favorites option

## Workflow

### 1. Project Setup

1. Created Flutter project using `flutter create`
2. Added required dependencies to `pubspec.yaml`
3. Ran `flutter pub get` to install packages

### 2. Model Implementation

1. Created `Book` class with all required properties
2. Implemented JSON parsing for Google Books API response
3. Added SQLite mapping methods

### 3. Service Layer Development

1. **Database Service**:
   - Set up SQLite database with favorites table
   - Implemented CRUD operations
   - Added database initialization and management
2. **API Service**:
   - Implemented Google Books API integration
   - Added search functionality with query encoding
   - Implemented error handling

### 4. UI Development

1. **Home Screen**:
   - Created search interface with TextField
   - Implemented book search with loading states
   - Added favorite toggle functionality
   - Integrated with both API and database services
2. **Favorites Screen**:
   - Created favorites list display
   - Added delete functionality with confirmation
   - Implemented book details view
   - Added clear all functionality

### 5. App Integration

1. Updated `main.dart` to use the new app structure
2. Set up navigation between screens
3. Updated test files to match new app structure

### 6. Testing and Validation

1. Updated widget tests for the new app structure
2. Verified API integration works correctly
3. Tested database operations
4. Validated UI responsiveness and user experience

## Key Features Implementation

### Favorite Button Logic

- **Empty Heart** (🤍): Book is not in favorites
- **Filled Heart** (❤️): Book is already in favorites
- **Action**: Clicking toggles the favorite status and updates the database

### FutureBuilder Usage

- Used for asynchronous operations (API calls, database queries)
- Provides loading states and error handling
- Ensures smooth user experience during data operations

### Error Handling

- Network error handling for API calls
- Database error handling with user feedback
- Graceful fallbacks for missing book images

## Running the Application

1. Ensure Flutter is installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Future Enhancements

- Book details page with full description
- Search history
- Categories and filtering
- Reading progress tracking
- Book recommendations
- Export/import favorites functionality

## Development Notes

- The app follows Flutter best practices with proper separation of concerns
- Uses Material Design 3 for modern UI components
- Implements proper state management for favorites
- Includes comprehensive error handling and user feedback
- Responsive design works on various screen sizes
