import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Content Management
  Future<void> addContent(ContentItem content) async {
    try {
      await _firestore.collection('content').doc(content.id).set(content.toJson());
    } catch (e) {
      throw Exception('Failed to add content: $e');
    }
  }

  Future<void> updateContent(ContentItem content) async {
    try {
      await _firestore.collection('content').doc(content.id).update(content.toJson());
    } catch (e) {
      throw Exception('Failed to update content: $e');
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to delete content: $e');
    }
  }

  Future<List<ContentItem>> getAllContent() async {
    try {
      final querySnapshot = await _firestore
          .collection('content')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ContentItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get content: $e');
    }
  }

  Future<List<ContentItem>> getContentByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('content')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ContentItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get content by category: $e');
    }
  }

  Future<ContentItem?> getContentById(String id) async {
    try {
      final doc = await _firestore.collection('content').doc(id).get();
      if (doc.exists) {
        return ContentItem.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get content: $e');
    }
  }

  // Learning Plans Management
  Future<void> addLearningPlan(Map<String, dynamic> plan) async {
    try {
      await _firestore.collection('learning_plans').doc(plan['id']).set(plan);
    } catch (e) {
      throw Exception('Failed to add learning plan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllLearningPlans() async {
    try {
      final querySnapshot = await _firestore
          .collection('learning_plans')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get learning plans: $e');
    }
  }

  // User Management (for admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get total users count
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      // Get total content count
      final contentSnapshot = await _firestore
          .collection('content')
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      // Get learning plans count
      final plansSnapshot = await _firestore
          .collection('learning_plans')
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return {
        'totalUsers': usersSnapshot.count,
        'totalContent': contentSnapshot.count,
        'totalPlans': plansSnapshot.count,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // Real-time streams for live updates
  Stream<List<ContentItem>> getContentStream() {
    return _firestore
        .collection('content')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContentItem.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Batch operations
  Future<void> batchAddContent(List<ContentItem> contentList) async {
    try {
      final batch = _firestore.batch();
      
      for (final content in contentList) {
        final docRef = _firestore.collection('content').doc(content.id);
        batch.set(docRef, content.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch add content: $e');
    }
  }

  // Seed initial data
  Future<void> seedFirestoreData() async {
    try {
      // Check if data already exists
      final contentSnapshot = await _firestore.collection('content').limit(1).get();
      if (contentSnapshot.docs.isNotEmpty) {
        return; // Data already seeded
      }

      // Add sample content and learning plans
      // This will be called once during app initialization
      print('Seeding Firestore with initial data...');
      
      // You can add your seeding logic here
      // For now, we'll just mark it as ready for manual content addition
      
    } catch (e) {
      print('Error seeding Firestore data: $e');
    }
  }
}