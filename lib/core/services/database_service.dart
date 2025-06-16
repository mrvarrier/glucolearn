import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'glucolearn.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'patient',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Medical profiles table
    await db.execute('''
      CREATE TABLE medical_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        diabetes_type TEXT NOT NULL,
        diagnosis_date INTEGER,
        hba1c REAL,
        complications TEXT,
        healthcare_provider TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Treatments table
    await db.execute('''
      CREATE TABLE treatments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        treatment_name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        start_date INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Learning plans table
    await db.execute('''
      CREATE TABLE learning_plans (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        target_diabetes_types TEXT,
        target_treatments TEXT,
        estimated_duration INTEGER,
        difficulty INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        created_by TEXT
      )
    ''');

    // Content items table
    await db.execute('''
      CREATE TABLE content_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        content_type TEXT NOT NULL,
        category TEXT NOT NULL,
        video_path TEXT,
        slides_data TEXT,
        questions_data TEXT,
        duration INTEGER,
        points_value INTEGER DEFAULT 0,
        tags TEXT,
        file_size INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        created_by TEXT,
        thumbnail_path TEXT,
        difficulty_level INTEGER DEFAULT 1
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        content_id TEXT NOT NULL,
        progress_percentage REAL DEFAULT 0,
        time_spent INTEGER DEFAULT 0,
        points_earned INTEGER DEFAULT 0,
        completed_at INTEGER,
        last_accessed INTEGER,
        watch_time INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (content_id) REFERENCES content_items (id)
      )
    ''');

    // Quiz attempts table
    await db.execute('''
      CREATE TABLE quiz_attempts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        content_id TEXT NOT NULL,
        score REAL NOT NULL,
        max_score REAL NOT NULL,
        answers TEXT NOT NULL,
        time_taken INTEGER,
        completed_at INTEGER NOT NULL,
        attempt_number INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (content_id) REFERENCES content_items (id)
      )
    ''');

    // User plan assignments table
    await db.execute('''
      CREATE TABLE user_plan_assignments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        plan_id TEXT NOT NULL,
        assigned_at INTEGER NOT NULL,
        started_at INTEGER,
        completed_at INTEGER,
        progress_percentage REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (plan_id) REFERENCES learning_plans (id)
      )
    ''');

    // Progress stats table
    await db.execute('''
      CREATE TABLE progress_stats (
        user_id TEXT PRIMARY KEY,
        total_points_earned INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_active_date INTEGER,
        total_lessons_completed INTEGER DEFAULT 0,
        total_quizzes_completed INTEGER DEFAULT 0,
        total_time_spent INTEGER DEFAULT 0,
        badges_earned TEXT,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_user_progress_user_id ON user_progress(user_id)');
    await db.execute('CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id)');
    await db.execute('CREATE INDEX idx_content_items_category ON content_items(category)');
    await db.execute('CREATE INDEX idx_content_items_type ON content_items(content_type)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Content operations
  Future<int> insertContent(Map<String, dynamic> content) async {
    final db = await database;
    return await db.insert('content_items', content);
  }

  Future<List<Map<String, dynamic>>> getContentByCategory(String category) async {
    final db = await database;
    return await db.query(
      'content_items',
      where: 'category = ? AND is_active = 1',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllContent() async {
    final db = await database;
    return await db.query(
      'content_items',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getContentById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Progress operations
  Future<int> insertOrUpdateProgress(Map<String, dynamic> progress) async {
    final db = await database;
    
    // Check if progress already exists
    final existing = await db.query(
      'user_progress',
      where: 'user_id = ? AND content_id = ?',
      whereArgs: [progress['user_id'], progress['content_id']],
    );
    
    if (existing.isNotEmpty) {
      return await db.update(
        'user_progress',
        progress,
        where: 'user_id = ? AND content_id = ?',
        whereArgs: [progress['user_id'], progress['content_id']],
      );
    } else {
      return await db.insert('user_progress', progress);
    }
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    final db = await database;
    return await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_accessed DESC',
    );
  }

  Future<Map<String, dynamic>?> getProgressByContentId(String userId, String contentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'user_id = ? AND content_id = ?',
      whereArgs: [userId, contentId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Quiz attempt operations
  Future<int> insertQuizAttempt(Map<String, dynamic> attempt) async {
    final db = await database;
    return await db.insert('quiz_attempts', attempt);
  }

  Future<List<Map<String, dynamic>>> getQuizAttempts(String userId, String contentId) async {
    final db = await database;
    return await db.query(
      'quiz_attempts',
      where: 'user_id = ? AND content_id = ?',
      whereArgs: [userId, contentId],
      orderBy: 'completed_at DESC',
    );
  }

  // Learning plan operations
  Future<int> insertLearningPlan(Map<String, dynamic> plan) async {
    final db = await database;
    return await db.insert('learning_plans', plan);
  }

  Future<List<Map<String, dynamic>>> getAllLearningPlans() async {
    final db = await database;
    return await db.query(
      'learning_plans',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getLearningPlanById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'learning_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // User plan assignment operations
  Future<int> assignPlanToUser(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.insert('user_plan_assignments', assignment);
  }

  Future<List<Map<String, dynamic>>> getUserPlanAssignments(String userId) async {
    final db = await database;
    return await db.query(
      'user_plan_assignments',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'assigned_at DESC',
    );
  }

  Future<int> updatePlanAssignment(String id, Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.update(
      'user_plan_assignments',
      assignment,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Progress stats operations
  Future<int> insertOrUpdateProgressStats(Map<String, dynamic> stats) async {
    final db = await database;
    
    // Check if stats already exist
    final existing = await db.query(
      'progress_stats',
      where: 'user_id = ?',
      whereArgs: [stats['user_id']],
    );
    
    if (existing.isNotEmpty) {
      return await db.update(
        'progress_stats',
        stats,
        where: 'user_id = ?',
        whereArgs: [stats['user_id']],
      );
    } else {
      return await db.insert('progress_stats', stats);
    }
  }

  Future<Map<String, dynamic>?> getProgressStats(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'progress_stats',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Utility methods
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('users');
    await db.delete('medical_profiles');
    await db.delete('treatments');
    await db.delete('learning_plans');
    await db.delete('content_items');
    await db.delete('user_progress');
    await db.delete('quiz_attempts');
    await db.delete('user_plan_assignments');
    await db.delete('progress_stats');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}