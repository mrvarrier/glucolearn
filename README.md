# GlucoLearn - Diabetes Education App

A comprehensive diabetes education Flutter app that helps diabetes patients learn through interactive content while tracking their progress. The app follows Apple's design system principles for a clean, intuitive, and accessible user experience.

## Features

### 🎓 Interactive Learning
- **Video Lessons**: Comprehensive diabetes education through high-quality videos
- **Interactive Slides**: Slide presentations with rich content
- **Downloadable Resources**: PDFs and documents for offline learning
- **Audio Content**: Accessibility-focused audio lessons

### 📊 Progress Tracking
- **Real-time Progress**: Track completion of lessons and quizzes
- **Learning Streaks**: Maintain daily learning habits
- **Points & Badges**: Gamification to encourage continued learning
- **Analytics Dashboard**: Detailed progress reports and insights

### 🧪 Quiz System
- **Multiple Question Types**: Multiple choice, true/false, drag & drop, image-based, and scenario-based questions
- **Adaptive Learning**: Difficulty adjusts based on performance
- **Instant Feedback**: Immediate results with detailed explanations
- **Spaced Repetition**: Review incorrect answers for better retention

### 🔐 Security & Privacy
- **Local Storage**: All data stored securely on device
- **No Cloud Dependency**: Complete offline functionality
- **Encrypted Data**: Password hashing and secure local authentication
- **HIPAA Compliant**: Designed with healthcare privacy in mind

### 👨‍⚕️ Medical Integration
- **Personalized Content**: Learning plans based on diabetes type and treatment
- **Medical Profile**: Track diagnosis date, HbA1c, treatments, and complications
- **Healthcare Provider Info**: Store doctor and clinic information

## Getting Started

### Prerequisites

- Flutter SDK 3.29.3 or higher
- Dart SDK 3.7.2 or higher
- Java 17 (for Android development)
- Xcode (for iOS development, optional)
- iOS Simulator or Android Emulator

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd diabetesapp
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Java (Required for Android)**
   ```bash
   # Install Java 17 via Homebrew (macOS)
   brew install openjdk@17
   
   # Configure Flutter to use Java 17
   flutter config --jdk-dir="/opt/homebrew/opt/openjdk@17"
   ```

5. **Verify setup**
   ```bash
   flutter doctor
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Troubleshooting

**Java Runtime Issues:**
- Ensure Java 17 is installed and configured
- Android Gradle Plugin requires Java 17 minimum

**File Picker Issues:**
- The app uses file_picker v8.3.7+ which resolved platform implementation warnings

**Build Issues:**
- Run `flutter clean` and `flutter pub get` to refresh dependencies
- Ensure Android NDK version 27.0.12077973 is installed

### Demo Accounts

The app comes pre-seeded with demo accounts for testing:

**Patient Account:**
- Email: `patient@demo.com`
- Password: `demo123`

**Admin Account:**
- Email: `admin@demo.com`
- Password: `admin123`

## Architecture

### Technology Stack
- **Framework**: Flutter 3.29.3+
- **Language**: Dart 3.7.2+
- **State Management**: Riverpod 2.4.9
- **Navigation**: GoRouter 12.1.3
- **Local Database**: SQLite (Sqflite 2.3.0)
- **Object Storage**: Hive 2.2.3
- **Video Player**: Chewie 1.7.4 + Video Player 2.8.1
- **Forms**: Flutter Form Builder 9.1.1
- **Charts**: FL Chart 0.65.0
- **Authentication**: Local authentication with Crypto 3.0.3
- **File Picker**: File Picker 8.3.7
- **Permissions**: Permission Handler 11.1.0

### Key Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  go_router: ^12.1.3            # Navigation
  sqflite: ^2.3.0               # Local database
  hive: ^2.2.3                  # Object storage
  video_player: ^2.8.1          # Video playback
  chewie: ^1.7.4                # Video player UI
  fl_chart: ^0.65.0             # Charts and analytics
  file_picker: ^8.3.7           # File selection
  crypto: ^3.0.3                # Password hashing
  flutter_form_builder: ^9.1.1  # Forms
  cached_network_image: ^3.3.0  # Image caching
  lottie: ^2.7.0                # Animations
```

## Project Structure
```
lib/
├── main.dart
├── app/                        # Main app configuration
├── core/                       # Core functionality and models
├── features/                   # Feature-based modules
└── shared/                     # Shared components
```

## Key Features Implemented

✅ **Complete Authentication System** with local storage and password hashing  
✅ **Medical Profile Onboarding** with diabetes type and treatment tracking  
✅ **Interactive Dashboard** with progress overview and quick actions  
✅ **Content Library** with search functionality and categorized materials  
✅ **Quiz System** with filtering, navigation and scoring  
✅ **Progress Analytics** with date range picker, streaks, and achievements  
✅ **User Profile Management** with edit functionality and medical information  
✅ **Admin Panel** with refresh, upload options, and management dialogs  
✅ **Apple Design System** implementation throughout  
✅ **Local Database** with SQLite and comprehensive sample data seeding  
✅ **Simplified UI Components** for better performance and stability  
✅ **Comprehensive Navigation** with proper routing and error handling  

## Recent Updates

### v1.0.1 - Latest
- **🔧 Fixed Authentication Flow**: Resolved login type conversion errors
- **📱 Simplified Medical Onboarding**: Replaced complex stepper with clean form layout
- **🏠 Enhanced Dashboard**: Streamlined dashboard with embedded components
- **🔍 Improved Search**: Added content search with suggestions
- **📊 Date Range Picker**: Added progress filtering by date range
- **🎯 Quiz Filtering**: Enhanced quiz filtering with modal bottom sheet
- **⚡ Performance Improvements**: Simplified complex widgets for better rendering
- **🐛 Bug Fixes**: Resolved blank page issues and navigation problems

## Security & Privacy

- **Local-First Architecture**: All data stored on device
- **Encrypted Storage**: Hive encryption for sensitive data
- **Secure Authentication**: SHA-256 password hashing
- **No External Dependencies**: Complete offline functionality
- **Privacy by Design**: Minimal data collection

## Development

### Code Quality
- **Static Analysis**: Enabled with `flutter analyze`
- **Linting**: Flutter lints package for code standards
- **Architecture**: Feature-based modular structure
- **State Management**: Centralized with Riverpod providers
- **Error Handling**: Comprehensive error boundaries and user feedback

### Testing
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Generate coverage report
flutter test --coverage
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires Xcode)
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting with `dart format`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

