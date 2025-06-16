import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/content.dart';
import 'database_service.dart';

class DataSeedingService {
  static final DataSeedingService _instance = DataSeedingService._internal();
  factory DataSeedingService() => _instance;
  DataSeedingService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> seedDatabase() async {
    try {
      // Check if data already exists
      final existingUsers = await _databaseService.getUserByEmail('patient@demo.com');
      if (existingUsers != null) {
        // Data already seeded
        return;
      }

      await _seedDemoUsers();
      await _seedLearningPlans();
      await _seedContent();
      await _seedUserProgressData();
      
      debugPrint('Database seeded successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }

  Future<void> _seedDemoUsers() async {
    final now = DateTime.now();

    // Demo Patient User
    final patientUserId = _uuid.v4();
    await _databaseService.insertUser({
      'id': patientUserId,
      'email': 'patient@demo.com',
      'password_hash': _hashPassword('demo123'),
      'name': 'John Patient',
      'role': UserRole.patient.name,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
      'is_active': 1,
    });

    // Demo Admin User
    final adminUserId = _uuid.v4();
    await _databaseService.insertUser({
      'id': adminUserId,
      'email': 'admin@demo.com',
      'password_hash': _hashPassword('admin123'),
      'name': 'Admin User',
      'role': UserRole.admin.name,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
      'is_active': 1,
    });

    debugPrint('Demo users created successfully');
  }

  Future<void> _seedLearningPlans() async {
    final now = DateTime.now();

    final plans = [
      {
        'id': _uuid.v4(),
        'title': 'Type 2 Diabetes Fundamentals',
        'description': 'Essential knowledge for newly diagnosed Type 2 diabetes patients',
        'target_diabetes_types': jsonEncode(['type2']),
        'target_treatments': jsonEncode(['metformin', 'diet_only']),
        'estimated_duration': 8, // hours
        'difficulty': 1,
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
      },
      {
        'id': _uuid.v4(),
        'title': 'Advanced Blood Sugar Management',
        'description': 'Advanced techniques for managing blood glucose levels',
        'target_diabetes_types': jsonEncode(['type1', 'type2']),
        'target_treatments': jsonEncode(['insulin', 'metformin']),
        'estimated_duration': 12,
        'difficulty': 3,
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
      },
      {
        'id': _uuid.v4(),
        'title': 'Nutrition for Diabetes',
        'description': 'Comprehensive guide to healthy eating with diabetes',
        'target_diabetes_types': jsonEncode(['type1', 'type2', 'gestational']),
        'target_treatments': jsonEncode(['diet_only', 'metformin', 'insulin']),
        'estimated_duration': 6,
        'difficulty': 2,
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
      },
    ];

    for (final plan in plans) {
      await _databaseService.insertLearningPlan(plan);
    }

    debugPrint('Learning plans created successfully');
  }

  Future<void> _seedContent() async {
    final now = DateTime.now();

    final contentItems = [
      // Understanding Diabetes Content
      {
        'id': _uuid.v4(),
        'title': 'What is Type 2 Diabetes?',
        'description': 'Learn the basics of Type 2 diabetes and how it affects your body.',
        'content_type': ContentType.video.name,
        'category': 'Understanding Diabetes',
        'video_path': 'assets/videos/type2_basics.mp4',
        'slides_data': null,
        'questions_data': null,
        'duration': 15,
        'points_value': 50,
        'tags': jsonEncode(['basics', 'type2', 'beginner']),
        'file_size': 45000000, // 45MB
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
        'thumbnail_path': 'assets/images/type2_basics_thumb.jpg',
        'difficulty_level': 1,
      },
      {
        'id': _uuid.v4(),
        'title': 'Understanding Blood Sugar',
        'description': 'Learn how blood sugar works and why it matters for diabetes management.',
        'content_type': ContentType.slides.name,
        'category': 'Understanding Diabetes',
        'video_path': null,
        'slides_data': jsonEncode([
          {
            'id': _uuid.v4(),
            'title': 'What is Blood Sugar?',
            'content': 'Blood sugar, also known as blood glucose, is the main sugar found in your blood.',
            'imagePath': null,
            'order': 1,
            'type': SlideType.text.name,
          },
          {
            'id': _uuid.v4(),
            'title': 'Normal Blood Sugar Levels',
            'content': 'Normal fasting blood sugar: 80-100 mg/dL\nNormal post-meal: Less than 140 mg/dL',
            'imagePath': 'assets/images/blood_sugar_chart.jpg',
            'order': 2,
            'type': SlideType.textImage.name,
          },
        ]),
        'questions_data': null,
        'duration': 10,
        'points_value': 30,
        'tags': jsonEncode(['blood sugar', 'glucose', 'basics']),
        'file_size': null,
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
        'thumbnail_path': 'assets/images/blood_sugar_thumb.jpg',
        'difficulty_level': 1,
      },
      // Blood Sugar Management Content
      {
        'id': _uuid.v4(),
        'title': 'Blood Sugar Monitoring Techniques',
        'description': 'Learn proper techniques for monitoring your blood glucose levels.',
        'content_type': ContentType.video.name,
        'category': 'Blood Sugar Management',
        'video_path': 'assets/videos/monitoring_techniques.mp4',
        'slides_data': null,
        'questions_data': null,
        'duration': 20,
        'points_value': 60,
        'tags': jsonEncode(['monitoring', 'glucometer', 'technique']),
        'file_size': 60000000, // 60MB
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
        'thumbnail_path': 'assets/images/monitoring_thumb.jpg',
        'difficulty_level': 2,
      },
      // Quiz Content
      {
        'id': _uuid.v4(),
        'title': 'Diabetes Basics Quiz',
        'description': 'Test your understanding of Type 2 diabetes fundamentals.',
        'content_type': ContentType.quiz.name,
        'category': 'Understanding Diabetes',
        'video_path': null,
        'slides_data': null,
        'questions_data': jsonEncode([
          {
            'id': _uuid.v4(),
            'question': 'What is the main cause of Type 2 diabetes?',
            'type': QuestionType.multipleChoice.name,
            'options': [
              {
                'id': _uuid.v4(),
                'text': 'Insulin resistance',
                'imagePath': null,
                'order': 1,
              },
              {
                'id': _uuid.v4(),
                'text': 'Too much sugar consumption',
                'imagePath': null,
                'order': 2,
              },
              {
                'id': _uuid.v4(),
                'text': 'Lack of exercise',
                'imagePath': null,
                'order': 3,
              },
              {
                'id': _uuid.v4(),
                'text': 'Genetic factors only',
                'imagePath': null,
                'order': 4,
              },
            ],
            'correctAnswers': [_uuid.v4()], // First option ID
            'explanation': 'Type 2 diabetes is primarily caused by insulin resistance, where the body\'s cells don\'t respond properly to insulin.',
            'points': 10,
            'imagePath': null,
            'difficultyLevel': 1,
            'tags': ['basics', 'type2'],
          },
          {
            'id': _uuid.v4(),
            'question': 'Normal fasting blood sugar level is below 100 mg/dL.',
            'type': QuestionType.trueFalse.name,
            'options': [
              {
                'id': _uuid.v4(),
                'text': 'True',
                'imagePath': null,
                'order': 1,
              },
              {
                'id': _uuid.v4(),
                'text': 'False',
                'imagePath': null,
                'order': 2,
              },
            ],
            'correctAnswers': [_uuid.v4()], // True option ID
            'explanation': 'Normal fasting blood sugar is indeed below 100 mg/dL (specifically 80-99 mg/dL).',
            'points': 5,
            'imagePath': null,
            'difficultyLevel': 1,
            'tags': ['blood sugar', 'normal values'],
          },
        ]),
        'duration': 15,
        'points_value': 100,
        'tags': jsonEncode(['quiz', 'basics', 'assessment']),
        'file_size': null,
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
        'thumbnail_path': 'assets/images/quiz_thumb.jpg',
        'difficulty_level': 1,
      },
      // Nutrition Content
      {
        'id': _uuid.v4(),
        'title': 'Healthy Meal Planning for Diabetes',
        'description': 'Learn how to plan balanced meals that help manage blood sugar.',
        'content_type': ContentType.video.name,
        'category': 'Nutrition & Diet',
        'video_path': 'assets/videos/meal_planning.mp4',
        'slides_data': null,
        'questions_data': null,
        'duration': 25,
        'points_value': 75,
        'tags': jsonEncode(['nutrition', 'meal planning', 'diet']),
        'file_size': 75000000, // 75MB
        'is_active': 1,
        'created_at': now.millisecondsSinceEpoch,
        'created_by': 'system',
        'thumbnail_path': 'assets/images/meal_planning_thumb.jpg',
        'difficulty_level': 2,
      },
    ];

    for (final content in contentItems) {
      await _databaseService.insertContent(content);
    }

    debugPrint('Content items created successfully');
  }

  Future<void> _seedUserProgressData() async {
    // Get demo patient user
    final patientUser = await _databaseService.getUserByEmail('patient@demo.com');
    if (patientUser == null) return;

    final userId = patientUser['id'];
    final now = DateTime.now();

    // Get some content items
    final allContent = await _databaseService.getAllContent();
    if (allContent.isEmpty) return;

    // Create some progress data
    for (int i = 0; i < 2 && i < allContent.length; i++) {
      final content = allContent[i];
      final progressId = _uuid.v4();
      
      await _databaseService.insertOrUpdateProgress({
        'id': progressId,
        'user_id': userId,
        'content_id': content['id'],
        'progress_percentage': i == 0 ? 100.0 : 65.0,
        'time_spent': i == 0 ? 900 : 600, // seconds
        'points_earned': i == 0 ? content['points_value'] : 0,
        'completed_at': i == 0 ? now.millisecondsSinceEpoch : null,
        'last_accessed': now.subtract(Duration(hours: i + 1)).millisecondsSinceEpoch,
        'watch_time': i == 0 ? 900 : 600,
        'created_at': now.subtract(Duration(days: i + 1)).millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });
    }

    // Create progress stats
    await _databaseService.insertOrUpdateProgressStats({
      'user_id': userId,
      'total_points_earned': 50,
      'current_streak': 3,
      'longest_streak': 7,
      'last_active_date': now.millisecondsSinceEpoch,
      'total_lessons_completed': 1,
      'total_quizzes_completed': 0,
      'total_time_spent': 15, // minutes
      'badges_earned': jsonEncode(['first_lesson', 'early_bird']),
      'updated_at': now.millisecondsSinceEpoch,
    });

    debugPrint('User progress data created successfully');
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllTables();
    debugPrint('All data cleared successfully');
  }
}