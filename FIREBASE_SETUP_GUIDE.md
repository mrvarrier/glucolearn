# Firebase Setup Guide for GlucoLearn

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
1. Visit [https://console.firebase.google.com](https://console.firebase.google.com)
2. Sign in with your Google account
3. Click **"Create a project"**

### 1.2 Project Configuration
1. **Project name**: `glucolearn` (or your preferred name)
2. **Enable Google Analytics**: ✅ Yes (recommended)
3. **Analytics account**: Use default or create new
4. Click **"Create project"**
5. Wait for project creation (30-60 seconds)

## Step 2: Enable Authentication

### 2.1 Enable Authentication Service
1. In Firebase Console, go to **Authentication** → **Get started**
2. Go to **Sign-in method** tab
3. Enable **Email/Password**:
   - Click on **Email/Password**
   - Toggle **Enable** ✅
   - Click **Save**

### 2.2 Create Test Users (Optional)
1. Go to **Authentication** → **Users** tab
2. Click **Add user**
3. Create admin user:
   - Email: `admin@glucolearn.com`
   - Password: `admin123!`
4. Create patient user:
   - Email: `patient@glucolearn.com` 
   - Password: `patient123!`

## Step 3: Setup Firestore Database

### 3.1 Create Firestore Database
1. Go to **Firestore Database** → **Create database**
2. **Security rules**: Start in **test mode** (we'll secure later)
3. **Location**: Choose closest to your users (e.g., `us-central1`)
4. Click **Done**

### 3.2 Create Collections Structure
Create these collections manually:

**Collection: `users`**
```
users/
├── {userId}/
    ├── email: string
    ├── name: string
    ├── role: string ("patient" | "admin")
    ├── createdAt: timestamp
    ├── updatedAt: timestamp
    ├── isActive: boolean
    └── preferences: object
```

**Collection: `content`**
```
content/
├── {contentId}/
    ├── title: string
    ├── description: string
    ├── category: string
    ├── type: string
    ├── isActive: boolean
    ├── createdAt: timestamp
    └── createdBy: string
```

## Step 4: Install Firebase CLI

### 4.1 Install Node.js (if not installed)
- Download from [https://nodejs.org](https://nodejs.org)
- Install LTS version

### 4.2 Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 4.3 Login to Firebase
```bash
firebase login
```
- Browser will open for Google authentication
- Allow Firebase CLI access

## Step 5: Configure Flutter App

### 5.1 Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 5.2 Configure Firebase for Flutter
```bash
cd /Users/manishvarrier/Desktop/glucolearn
flutterfire configure
```

Follow the prompts:
1. **Select project**: Choose your `glucolearn` project
2. **Select platforms**: 
   - ✅ iOS
   - ✅ Android
   - ✅ Web
   - ✅ macOS (if needed)
3. **iOS bundle ID**: `com.yourcompany.glucolearn`
4. **Android package**: `com.yourcompany.glucolearn`

This will:
- Create/update `firebase_options.dart`
- Configure platform-specific files
- Set up Firebase SDK

## Step 6: Update Configuration Files

### 6.1 Replace firebase_options.dart
The FlutterFire CLI will automatically generate the correct `firebase_options.dart` file with your real project credentials, replacing the demo one.

### 6.2 Update Android Configuration
Check that `android/app/google-services.json` was created by FlutterFire CLI.

### 6.3 Update iOS Configuration  
Check that `ios/Runner/GoogleService-Info.plist` was created by FlutterFire CLI.

## Step 7: Set Up Firestore Security Rules

### 7.1 Create Security Rules
In Firebase Console → **Firestore Database** → **Rules**, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // All authenticated users can read content
    match /content/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }
    
    // Only admins can manage learning plans
    match /learning_plans/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }
    
    // Admin-only collections
    match /analytics/{document} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }
  }
}
```

### 7.2 Publish Rules
Click **Publish** to activate the security rules.

## Step 8: Test Firebase Integration

### 8.1 Run the App
```bash
cd /Users/manishvarrier/Desktop/glucolearn
flutter clean
flutter pub get
flutter run
```

### 8.2 Test Authentication
1. **Sign Up**: Create a new account
2. **Sign In**: Use the test accounts
3. **Check Console**: Verify users appear in Firebase Authentication

### 8.3 Test Firestore
1. **Admin Dashboard**: Login as admin and check analytics
2. **Content**: Verify content loads (may be empty initially)
3. **Check Console**: See data in Firestore Database

## Step 9: Seed Initial Data

### 9.1 Create Sample Content (Optional)
In Firebase Console → **Firestore Database**, manually add sample content:

**Document in `content` collection:**
```json
{
  "title": "Understanding Type 2 Diabetes",
  "description": "Learn the basics of Type 2 diabetes",
  "category": "Understanding Diabetes",
  "type": "video",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "createdBy": "system",
  "duration": 15,
  "pointsValue": 50,
  "difficultyLevel": 1
}
```

### 9.2 Verify Data Flow
1. **Patient View**: Check if content appears
2. **Admin View**: Verify analytics show data
3. **Offline**: Turn off internet, app should still work

## Step 10: Production Considerations

### 10.1 Environment Setup
For production, consider:
- Separate Firebase projects for dev/staging/prod
- Environment-specific configuration
- Proper security rules testing

### 10.2 Security Hardening
- Review and test all security rules
- Enable App Check for additional security
- Set up Firebase Security Rules testing

### 10.3 Monitoring
- Enable Firebase Performance Monitoring
- Set up Crashlytics for error tracking
- Configure Firebase Analytics events

## Troubleshooting

### Common Issues

#### ❌ "Default FirebaseApp is not initialized"
**Solution**: Ensure `flutterfire configure` was run and `firebase_options.dart` exists

#### ❌ "Permission denied" in Firestore
**Solution**: Check security rules and user authentication

#### ❌ "Network error"
**Solution**: Check internet connection and Firebase project status

#### ❌ iOS build fails
**Solution**: Ensure `GoogleService-Info.plist` is in `ios/Runner/` directory

#### ❌ Android build fails
**Solution**: Ensure `google-services.json` is in `android/app/` directory

### Debug Commands
```bash
# Check Firebase projects
firebase projects:list

# Check FlutterFire status
flutterfire configure --dry-run

# Clear Flutter cache
flutter clean && flutter pub get

# Check Firebase connection
firebase functions:shell
```

## Verification Checklist

- [ ] Firebase project created
- [ ] Authentication enabled with Email/Password
- [ ] Firestore database created
- [ ] FlutterFire CLI configured
- [ ] `firebase_options.dart` updated with real credentials
- [ ] Security rules configured
- [ ] App builds and runs without errors
- [ ] Can create new user accounts
- [ ] Admin dashboard loads with real-time data
- [ ] Content management works (if admin)
- [ ] App works offline
- [ ] Local data (progress/medical) stays local

## Next Steps

After successful setup:
1. **Add real content** via admin dashboard
2. **Test all user flows** thoroughly
3. **Deploy to app stores** when ready
4. **Monitor usage** via Firebase Analytics
5. **Scale as needed** with Firebase's automatic scaling

---

**🎉 Congratulations! Your Firebase hybrid architecture is now fully operational!**