import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'firestore_service.dart';
import '../models/user.dart';
import '../models/content.dart';

class HybridDatabaseService {
  static final HybridDatabaseService _instance = HybridDatabaseService._internal();
  factory HybridDatabaseService() => _instance;
  HybridDatabaseService._internal();

  final DatabaseService _localDb = DatabaseService();
  final FirestoreService _firestore = FirestoreService();

  // Content Management - Uses Firestore for admin management, local for caching
  Future<List<ContentItem>> getAllContent() async {
    try {
      // Try to get from Firestore first (latest content)
      final firestoreContent = await _firestore.getAllContent();
      
      // Cache in local database for offline access
      for (final content in firestoreContent) {
        await _cacheContentLocally(content);
      }
      
      return firestoreContent;
    } catch (e) {
      // Fallback to local database if offline
      print('Firestore unavailable, using local cache: $e');
      return await _getLocalContent();
    }
  }

  Future<List<ContentItem>> getContentByCategory(String category) async {
    try {
      return await _firestore.getContentByCategory(category);
    } catch (e) {
      print('Firestore unavailable, using local cache: $e');
      return await _getLocalContentByCategory(category);
    }
  }

  Future<ContentItem?> getContentById(String id) async {
    try {
      return await _firestore.getContentById(id);
    } catch (e) {
      print('Firestore unavailable, using local cache: $e');
      return await _getLocalContentById(id);
    }
  }

  // Admin-only content management (requires internet)
  Future<void> addContent(ContentItem content) async {
    await _firestore.addContent(content);
    await _cacheContentLocally(content);
  }

  Future<void> updateContent(ContentItem content) async {
    await _firestore.updateContent(content);
    await _cacheContentLocally(content);
  }

  Future<void> deleteContent(String contentId) async {
    await _firestore.deleteContent(contentId);
    // Mark as inactive in local cache
    final localContent = await _localDb.getContentById(contentId);
    if (localContent != null) {
      await _localDb.insertContent({
        ...localContent,
        'is_active': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // User Progress Management - Always local for privacy
  Future<void> updateUserProgress(Map<String, dynamic> progress) async {
    await _localDb.insertOrUpdateProgress(progress);
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    return await _localDb.getUserProgress(userId);
  }

  Future<Map<String, dynamic>?> getProgressByContentId(String userId, String contentId) async {
    return await _localDb.getProgressByContentId(userId, contentId);
  }

  // Medical Profile Management - Always local for privacy
  Future<void> updateMedicalProfile(String userId, Map<String, dynamic> medicalProfile) async {
    // Store in local database only
    await _localDb.database.then((db) async {
      await db.insert('medical_profiles', {
        'id': medicalProfile['id'],
        'user_id': userId,
        ...medicalProfile,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Map<String, dynamic>?> getMedicalProfile(String userId) async {
    final db = await _localDb.database;
    final result = await db.query(
      'medical_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Quiz Attempts - Local for privacy
  Future<void> recordQuizAttempt(Map<String, dynamic> attempt) async {
    await _localDb.insertQuizAttempt(attempt);
  }

  Future<List<Map<String, dynamic>>> getQuizAttempts(String userId, String contentId) async {
    return await _localDb.getQuizAttempts(userId, contentId);
  }

  // Learning Plans - Hybrid: Firestore for admin management, local for user assignments
  Future<List<Map<String, dynamic>>> getAllLearningPlans() async {
    try {
      return await _firestore.getAllLearningPlans();
    } catch (e) {
      print('Firestore unavailable, using local cache: $e');
      return await _localDb.getAllLearningPlans();
    }
  }

  Future<void> assignPlanToUser(String userId, String planId) async {
    // Always store user assignments locally
    await _localDb.assignPlanToUser({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'plan_id': planId,
      'assigned_at': DateTime.now().millisecondsSinceEpoch,
      'is_active': 1,
      'progress_percentage': 0.0,
    });
  }

  Future<List<Map<String, dynamic>>> getUserPlanAssignments(String userId) async {
    return await _localDb.getUserPlanAssignments(userId);
  }

  // Analytics - Firestore for admin dashboard
  Future<Map<String, dynamic>> getAnalytics() async {
    return await _firestore.getAnalytics();
  }

  // User Management - Firestore for admin, local for current user data
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _firestore.getAllUsers();
  }

  // Sync utilities
  Future<void> syncContentToLocal() async {
    try {
      final firestoreContent = await _firestore.getAllContent();
      for (final content in firestoreContent) {
        await _cacheContentLocally(content);
      }
      print('Content synced successfully');
    } catch (e) {
      print('Failed to sync content: $e');
    }
  }

  // Private helper methods
  Future<void> _cacheContentLocally(ContentItem content) async {
    try {
      await _localDb.insertContent(content.toJson());
    } catch (e) {
      print('Failed to cache content locally: $e');
    }
  }

  Future<List<ContentItem>> _getLocalContent() async {
    final localData = await _localDb.getAllContent();
    return localData.map((data) => ContentItem.fromJson(data)).toList();
  }

  Future<List<ContentItem>> _getLocalContentByCategory(String category) async {
    final localData = await _localDb.getContentByCategory(category);
    return localData.map((data) => ContentItem.fromJson(data)).toList();
  }

  Future<ContentItem?> _getLocalContentById(String id) async {
    final localData = await _localDb.getContentById(id);
    return localData != null ? ContentItem.fromJson(localData) : null;
  }

  // Offline support check
  bool get isOnline {
    // In a real app, you'd check network connectivity
    // For now, we'll assume online
    return true;
  }

  // Data migration helpers
  Future<void> migrateLocalDataToFirestore() async {
    // Only run this once during migration
    try {
      final localPlans = await _localDb.getAllLearningPlans();
      for (final plan in localPlans) {
        await _firestore.addLearningPlan(plan);
      }
      print('Data migration completed');
    } catch (e) {
      print('Migration failed: $e');
    }
  }
}

