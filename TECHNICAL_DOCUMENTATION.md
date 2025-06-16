# GlucoLearn - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [State Management](#state-management)
5. [Data Layer](#data-layer)
6. [Authentication System](#authentication-system)
7. [Navigation & Routing](#navigation--routing)
8. [UI Components](#ui-components)
9. [Features Implementation](#features-implementation)
10. [Security Implementation](#security-implementation)
11. [Performance Considerations](#performance-considerations)
12. [Testing Strategy](#testing-strategy)

## Architecture Overview

GlucoLearn follows a **Feature-First Architecture** with **Clean Architecture** principles, implementing a local-first approach for maximum privacy and offline functionality.

### High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│                 Presentation Layer               │
│  (UI Widgets, Pages, State Management)          │
├─────────────────────────────────────────────────┤
│                 Business Logic Layer            │
│  (Providers, Services, Use Cases)               │
├─────────────────────────────────────────────────┤
│                 Data Layer                      │
│  (Local Database, Hive Storage, Models)         │
└─────────────────────────────────────────────────┘
```

### Design Patterns Used

- **Provider Pattern** (Riverpod) for state management
- **Repository Pattern** for data access abstraction
- **Service Layer Pattern** for business logic
- **Factory Pattern** for model creation
- **Observer Pattern** for reactive updates

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── app/                               # App-level configuration
│   ├── app.dart                       # Main app widget with initialization
│   ├── routes.dart                    # Navigation configuration
│   └── theme.dart                     # App theme and styling
├── core/                              # Core functionality
│   ├── constants/                     # App-wide constants
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_dimensions.dart       # Spacing and sizing
│   │   └── app_strings.dart          # Localized strings
│   ├── models/                        # Data models
│   │   ├── user.dart                 # User entity
│   │   ├── content.dart              # Learning content entity
│   │   └── progress.dart             # Progress tracking entity
│   ├── services/                      # Business logic services
│   │   ├── auth_service.dart         # Authentication logic
│   │   ├── database_service.dart     # Database operations
│   │   └── data_seeding_service.dart # Demo data generation
│   └── utils/                         # Utility functions
├── features/                          # Feature modules
│   ├── auth/                         # Authentication feature
│   │   ├── pages/                    # Auth UI screens
│   │   ├── providers/                # Auth state management
│   │   └── widgets/                  # Auth-specific widgets
│   ├── dashboard/                    # Dashboard feature
│   ├── learning/                     # Learning content feature
│   ├── quiz/                         # Quiz system feature
│   ├── progress/                     # Progress tracking feature
│   ├── profile/                      # User profile feature
│   ├── onboarding/                   # User onboarding feature
│   └── admin/                        # Admin panel feature
└── shared/                           # Shared components
    ├── extensions/                   # Dart extensions
    ├── validators/                   # Form validators
    └── widgets/                      # Reusable widgets
```

## Core Components

### 1. Main Application (`app/app.dart`)

```dart
class GlucoLearnApp extends ConsumerStatefulWidget {
  // Initializes core services on app startup
  // - Hive database
  // - Authentication service
  // - Demo data seeding
}
```

**Key Responsibilities:**
- Initialize Hive local database
- Set up authentication service
- Seed demo data for testing
- Configure app-wide providers

### 2. Route Configuration (`app/routes.dart`)

```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,  // Handles auth-based redirects
    routes: [...]
  );
}
```

**Features:**
- Nested routing with ShellRoute for bottom navigation
- Authentication-based route protection
- Onboarding flow management
- Admin-only route access

### 3. Theme System (`app/theme.dart`)

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // iOS-inspired design system
    // Custom color scheme
    // Typography scale
    // Component themes
  );
}
```

## State Management

### Riverpod Architecture

The app uses **Riverpod** for state management with the following provider types:

#### 1. StateProvider
```dart
final currentUserProvider = StateProvider<User?>((ref) => null);
```
- Simple state that can be read and modified
- Used for current user, theme mode, etc.

#### 2. StateNotifierProvider
```dart
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref);
});
```
- Complex state with business logic
- Used for authentication, form state, etc.

#### 3. Provider
```dart
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
```
- Immutable services and dependencies
- Used for service injection

### State Flow Example: Authentication

```
User Action (Login) 
    ↓
UI Layer (LoginPage)
    ↓
Provider (authStateProvider.notifier.signIn())
    ↓
Service Layer (AuthService.signIn())
    ↓
Data Layer (DatabaseService.getUserByEmail())
    ↓
Provider State Update
    ↓
UI Rebuild (Auto via ConsumerWidget)
```

## Data Layer

### Local Database (SQLite)

**Database Service** (`core/services/database_service.dart`):

```dart
class DatabaseService {
  // Creates and manages SQLite database
  // Tables: users, medical_profiles, content, progress, quizzes
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
}
```

**Schema Design:**

```sql
-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'patient',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_active INTEGER DEFAULT 1
);

-- Medical profiles table
CREATE TABLE medical_profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  diabetes_type TEXT NOT NULL,
  diagnosis_date INTEGER,
  hba1c REAL,
  complications TEXT,
  healthcare_provider TEXT,
  FOREIGN KEY (user_id) REFERENCES users (id)
);
```

### Object Storage (Hive)

**User Model** (`core/models/user.dart`):

```dart
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String email;
  @HiveField(2) String name;
  // ... other fields
  
  // Serialization methods
  Map<String, dynamic> toJson() { ... }
  factory User.fromJson(Map<String, dynamic> json) { ... }
}
```

**Benefits:**
- Type-safe object storage
- Automatic code generation
- Efficient binary serialization
- Cross-platform compatibility

## Authentication System

### Security Implementation

**Password Hashing** (`core/services/auth_service.dart`):

```dart
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

**Session Management:**

```dart
Future<void> _loadCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(_currentUserKey);
  
  if (userId != null) {
    final userData = await _databaseService.getUserById(userId);
    if (userData != null) {
      _currentUser = User.fromJson(_convertDbDataToJson(userData));
    }
  }
}
```

**Security Features:**
- SHA-256 password hashing
- Local session persistence
- Automatic session restoration
- Role-based access control

### Authentication Flow

1. **Login Process:**
   ```
   User Input → Validation → Hash Password → Database Query → 
   Session Creation → State Update → Navigation
   ```

2. **Registration Process:**
   ```
   User Input → Validation → Hash Password → Create User → 
   Database Insert → Auto Login → Onboarding Flow
   ```

3. **Session Restoration:**
   ```
   App Launch → Check Stored Session → Load User Data → 
   Update State → Route to Appropriate Screen
   ```

## Navigation & Routing

### GoRouter Configuration

**Route Structure:**
```dart
routes: [
  // Authentication routes (no auth required)
  GoRoute(path: '/login', ...),
  GoRoute(path: '/signup', ...),
  
  // Onboarding routes (auth required, no medical profile)
  GoRoute(path: '/welcome', ...),
  GoRoute(path: '/medical-info', ...),
  
  // Main app routes (auth + medical profile required)
  ShellRoute(
    builder: (context, state, child) => MainNavigationPage(child: child),
    routes: [
      GoRoute(path: '/', name: 'dashboard', ...),
      GoRoute(path: '/learn', ...),
      GoRoute(path: '/quiz', ...),
      GoRoute(path: '/progress', ...),
      GoRoute(path: '/profile', ...),
    ],
  ),
  
  // Admin routes (admin role required)
  GoRoute(path: '/admin', ...),
]
```

**Route Protection:**
```dart
static String? _redirect(BuildContext context, GoRouterState state) {
  final authService = AuthService();
  final isAuthenticated = authService.isAuthenticated;
  final currentUser = authService.currentUser;
  
  // Redirect logic based on auth state and user profile
  if (!isAuthenticated && !isOnAuthPages) {
    return '/login';
  }
  
  if (isAuthenticated && !hasCompletedOnboarding) {
    return '/welcome';
  }
  
  return null; // No redirect needed
}
```

### Bottom Navigation

**Implementation** (`features/dashboard/pages/main_navigation_page.dart`):

```dart
class MainNavigationPage extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [...], // Navigation items
      ),
    );
  }
}
```

## UI Components

### Design System

**Color Palette** (`core/constants/app_colors.dart`):
```dart
class AppColors {
  // Primary Colors (iOS Blue)
  static const Color primary = Color(0xFF007AFF);
  
  // Alert Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF2F2F7);
}
```

**Spacing System** (`core/constants/app_dimensions.dart`):
```dart
class AppDimensions {
  // 8pt grid system
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  
  // Consistent padding
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
}
```

### Reusable Widgets

**Progress Card Example:**
```dart
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            // Progress header
            Row(...),
            // Progress bar
            LinearProgressIndicator(...),
            // Progress details
            Row(...),
          ],
        ),
      ),
    );
  }
}
```

## Features Implementation

### 1. Dashboard Feature

**Architecture:**
```
DashboardPage (UI)
    ↓
ConsumerWidget (State Management)
    ↓
AuthProvider (Current User)
    ↓
Dashboard Components (UI Elements)
```

**Components:**
- **StreakCard**: Shows learning streak with fire icon
- **ProgressCard**: Current learning plan progress
- **GoalItems**: Daily learning goals checklist
- **QuickActions**: Navigation shortcuts

### 2. Learning Feature

**Content Library** (`features/learning/pages/content_library_page.dart`):

```dart
class ContentLibraryPage extends StatefulWidget {
  // Features:
  // - Content search with delegate
  // - Category filtering
  // - Content cards with progress
  // - Navigation to content detail
}
```

**Search Implementation:**
```dart
class ContentSearchDelegate extends SearchDelegate<String> {
  @override
  Widget buildResults(BuildContext context) {
    // Search implementation with suggestions
    return ListView.builder(...);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = ['Diabetes Types', 'Blood Sugar', ...];
    return ListView.builder(...);
  }
}
```

### 3. Quiz Feature

**Quiz List** (`features/quiz/pages/quiz_list_page.dart`):

```dart
class QuizListPage extends StatelessWidget {
  // Features:
  // - Quiz filtering by difficulty/status
  // - Progress indicators
  // - Score display
  // - Navigation to quiz detail
  
  Widget _buildQuizCard(BuildContext context, Map<String, dynamic> quiz) {
    return Card(
      child: InkWell(
        onTap: () => context.pushNamed('quiz-detail', pathParameters: {'id': quiz['id']}),
        child: // Quiz card content
      ),
    );
  }
}
```

**Filter Implementation:**
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    child: Column(
      children: [
        // Difficulty filters
        Wrap(
          children: [
            FilterChip(label: Text('Beginner'), ...),
            FilterChip(label: Text('Intermediate'), ...),
            FilterChip(label: Text('Advanced'), ...),
          ],
        ),
        // Status filters
        Wrap(...),
      ],
    ),
  ),
);
```

### 4. Progress Feature

**Progress Tracking** (`features/progress/pages/progress_page.dart`):

```dart
class ProgressPage extends StatefulWidget {
  // Features:
  // - Date range picker for filtering
  // - Overall statistics display
  // - Learning progress by category
  // - Quiz performance history
  // - Achievements system
  
  DateTimeRange? _selectedDateRange;
  
  // Date picker implementation
  final DateTimeRange? pickedRange = await showDateRangePicker(...);
}
```

### 5. Profile Feature

**Profile Management:**
- **View Profile**: Display user information and medical data
- **Edit Profile**: Comprehensive form for updating user data
- **Settings**: Notifications, privacy, export options

**Edit Profile Implementation:**
```dart
class EditProfilePage extends ConsumerStatefulWidget {
  // Form controllers for all fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Medical information
  String? _selectedDiabetesType;
  DateTime? _diagnosisDate;
  
  // Learning preferences
  int _dailyGoal = 30;
  String _difficultyLevel = 'beginner';
  bool _notificationsEnabled = true;
}
```

### 6. Admin Feature

**Admin Dashboard** (`features/admin/pages/admin_dashboard_page.dart`):

```dart
class AdminDashboardPage extends StatelessWidget {
  // Features:
  // - Overview statistics cards
  // - Quick action buttons
  // - Recent activity feed
  // - Content management dialogs
  // - User management placeholders
  
  Widget _buildActionTile(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: () => showDialog(...), // Feature dialogs
    );
  }
}
```

## Security Implementation

### Data Protection

1. **Local Storage Encryption:**
   ```dart
   // Hive boxes with encryption
   final encryptedBox = await Hive.openBox('secure_data', encryptionCipher: cipher);
   ```

2. **Password Security:**
   ```dart
   // SHA-256 hashing with salt
   String _hashPassword(String password) {
     final bytes = utf8.encode(password + salt);
     final digest = sha256.convert(bytes);
     return digest.toString();
   }
   ```

3. **Session Security:**
   ```dart
   // Automatic session timeout
   // Secure session storage
   // Session invalidation on logout
   ```

### Privacy Features

- **No Cloud Storage**: All data remains on device
- **No Analytics**: No user tracking or data collection
- **Local Authentication**: No external auth services
- **Encrypted Storage**: Sensitive data encrypted at rest

## Performance Considerations

### Optimization Strategies

1. **Widget Optimization:**
   ```dart
   // Use const constructors
   const SizedBox(height: AppDimensions.spaceMD)
   
   // Prefer specific rebuild widgets
   Consumer(builder: (context, ref, child) => ...)
   ```

2. **State Management:**
   ```dart
   // Selective watching
   final user = ref.watch(currentUserProvider.select((user) => user?.name));
   
   // Provider caching
   final authService = ref.read(authServiceProvider);
   ```

3. **Database Optimization:**
   ```dart
   // Indexed queries
   await db.query('users', where: 'email = ?', whereArgs: [email]);
   
   // Batch operations
   await db.transaction((txn) async { ... });
   ```

4. **Image Optimization:**
   ```dart
   // Cached network images
   CachedNetworkImage(
     imageUrl: url,
     placeholder: (context, url) => CircularProgressIndicator(),
     errorWidget: (context, url, error) => Icon(Icons.error),
   )
   ```

### Memory Management

- **Dispose Controllers**: Proper cleanup of TextEditingController
- **Cancel Subscriptions**: StreamSubscription disposal
- **Widget Lifecycle**: Proper use of StatefulWidget lifecycle methods

## Testing Strategy

### Unit Testing

```dart
// Service testing
test('AuthService should hash passwords correctly', () {
  final authService = AuthService();
  final hashedPassword = authService.hashPassword('test123');
  expect(hashedPassword, isNot('test123'));
  expect(hashedPassword.length, equals(64)); // SHA-256 length
});
```

### Widget Testing

```dart
// Widget testing
testWidgets('LoginPage should display email and password fields', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: LoginPage()),
    ),
  );
  
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Password'), findsOneWidget);
});
```

### Integration Testing

```dart
// Full user flow testing
testWidgets('User can complete onboarding flow', (WidgetTester tester) async {
  // Test complete user journey from signup to dashboard
});
```

## Error Handling

### Error Boundaries

```dart
// Global error handling
class ErrorBoundary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appStateProvider).when(
      data: (data) => MyApp(),
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error),
    );
  }
}
```

### User Feedback

```dart
// Consistent error messaging
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
    ),
  );
}
```

## Future Enhancements

### Planned Features

1. **Offline Sync**: Background data synchronization
2. **Push Notifications**: Learning reminders and updates
3. **Advanced Analytics**: Detailed learning insights
4. **Content Management**: Dynamic content loading
5. **Multi-language Support**: Localization framework
6. **Accessibility**: Enhanced screen reader support
7. **Testing Coverage**: Comprehensive test suite

### Technical Debt

1. **Code Generation**: Implement freezed for immutable models
2. **Dependency Injection**: Move to injectable/get_it
3. **Error Handling**: Implement Either/Result types
4. **Logging**: Add comprehensive logging system
5. **Performance Monitoring**: Add performance metrics

---

This technical documentation provides a comprehensive overview of the GlucoLearn codebase architecture, implementation details, and development practices. It serves as a guide for developers working on the project and helps maintain code quality and consistency.