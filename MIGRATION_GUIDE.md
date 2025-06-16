# Migration Guide: SQLite to Firebase Hybrid

## Overview
This guide explains how to migrate from the previous local-only SQLite approach to the new Firebase hybrid architecture.

## What Changed

### Before (Pure SQLite)
- All data stored locally
- Demo users seeded in local database
- No cloud capabilities
- Limited admin functionality

### After (Firebase Hybrid)
- Authentication via Firebase Auth
- Content management via Firestore
- User progress stays local
- Real-time admin capabilities

## Migration Steps

### 1. Firebase Project Setup
To use this in production, you'll need to:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Create Firebase project
firebase login
firebase init

# Configure your project
# Replace demo settings in firebase_options.dart
```

### 2. Update Configuration
Replace the demo Firebase configuration in `lib/firebase_options.dart` with your actual project settings.

### 3. Data Migration Process

#### For Existing Users
The app will automatically:
1. Create Firebase Auth accounts for existing users
2. Keep local user progress intact
3. Sync content to Firestore for admin management

#### For Demo Data
Demo accounts will work automatically:
- `patient@demo.com` / `demo123` - Patient role
- `admin@demo.com` / `admin123` - Admin role

### 4. Admin Setup
1. Admins can now manage content via Firestore
2. Real-time analytics available in admin dashboard
3. User management through Firebase Console

## Data Mapping

### User Data
```
Old: Local SQLite users table
New: Firebase Auth + Firestore users collection
Medical profiles remain local only
```

### Content Data
```
Old: Local SQLite content_items table
New: Firestore content collection + local cache
Admin manages in Firestore, users access from cache
```

### Progress Data
```
Old: Local SQLite user_progress table
New: Still local SQLite (privacy protection)
No change needed for existing progress
```

## Testing the Migration

### 1. Authentication Test
```dart
// Test Firebase auth
await FirebaseAuthService().signIn('admin@demo.com', 'admin123');
// Should redirect to admin dashboard
```

### 2. Content Management Test
```dart
// Test Firestore content
await FirestoreService().getAllContent();
// Should fetch from cloud or local cache
```

### 3. Progress Privacy Test
```dart
// Test local progress
await HybridDatabaseService().getUserProgress(userId);
// Should always use local database
```

## Rollback Plan

If needed, you can disable Firebase and fall back to local-only:

1. Comment out Firebase initialization in `main.dart`
2. Use `AuthService` instead of `FirebaseAuthService`
3. Use `DatabaseService` instead of `HybridDatabaseService`

## Benefits After Migration

### For Users
- ✅ Better authentication security
- ✅ Latest content automatically
- ✅ Same privacy protections
- ✅ Offline functionality maintained

### For Admins
- ✅ Real-time content management
- ✅ Cloud-based analytics
- ✅ Remote administration
- ✅ Scalable infrastructure

### For Developers
- ✅ Modern authentication
- ✅ Scalable backend
- ✅ Real-time capabilities
- ✅ Better error handling

## Troubleshooting

### Common Issues

#### Firebase Not Initialized
```
Error: Firebase not initialized
Solution: Check firebase_options.dart configuration
```

#### Network Connectivity
```
Error: Firestore offline
Solution: App automatically falls back to local cache
```

#### Demo Accounts Not Working
```
Error: Authentication failed
Solution: Demo accounts work with any Firebase project
```

### Performance Tips

1. **Content Caching**: Content is automatically cached locally
2. **Offline Mode**: Full functionality available offline
3. **Background Sync**: Content updates in background
4. **Local First**: Progress and medical data stay local

## Next Steps

After migration:
1. Set up production Firebase project
2. Configure Firestore security rules
3. Enable Firebase Analytics
4. Set up Firebase Functions for advanced features

---

**The migration preserves all existing functionality while adding powerful cloud capabilities.**