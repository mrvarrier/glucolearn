#!/bin/bash

# GlucoLearn Firebase Setup Script
echo "🔥 GlucoLearn Firebase Setup Script"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from the Flutter project root directory"
    exit 1
fi

echo "📋 This script will help you set up Firebase for GlucoLearn"
echo ""

# Step 1: Check prerequisites
echo "1️⃣ Checking prerequisites..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js from https://nodejs.org"
    exit 1
else
    echo "✅ Node.js is installed: $(node --version)"
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
else
    echo "✅ Flutter is installed: $(flutter --version | head -n 1)"
fi

# Step 2: Install Firebase CLI
echo ""
echo "2️⃣ Installing Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
    if [ $? -eq 0 ]; then
        echo "✅ Firebase CLI installed successfully"
    else
        echo "❌ Failed to install Firebase CLI"
        exit 1
    fi
else
    echo "✅ Firebase CLI is already installed: $(firebase --version)"
fi

# Step 3: Install FlutterFire CLI
echo ""
echo "3️⃣ Installing FlutterFire CLI..."
echo "📦 Installing FlutterFire CLI..."
dart pub global activate flutterfire_cli
if [ $? -eq 0 ]; then
    echo "✅ FlutterFire CLI installed successfully"
else
    echo "❌ Failed to install FlutterFire CLI"
    exit 1
fi

# Step 4: Login to Firebase
echo ""
echo "4️⃣ Firebase Authentication..."
echo "🔐 Please login to Firebase (browser will open)..."
firebase login --no-localhost
if [ $? -eq 0 ]; then
    echo "✅ Firebase login successful"
else
    echo "❌ Firebase login failed"
    exit 1
fi

# Step 5: List available projects
echo ""
echo "5️⃣ Available Firebase Projects:"
firebase projects:list

echo ""
echo "📝 Next Steps:"
echo "1. Create a new Firebase project at https://console.firebase.google.com if you haven't"
echo "2. Run: flutterfire configure"
echo "3. Follow the prompts to select your project and platforms"
echo "4. Enable Authentication and Firestore in Firebase Console"
echo "5. Run: flutter run"

echo ""
echo "📖 For detailed instructions, see: FIREBASE_SETUP_GUIDE.md"
echo ""
echo "🎉 Setup script completed! Ready for Firebase configuration."