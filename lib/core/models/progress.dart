import 'package:hive/hive.dart';

part 'progress.g.dart';

@HiveType(typeId: 13)
class UserProgress extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String contentId;

  @HiveField(3)
  double progressPercentage;

  @HiveField(4)
  int timeSpent; // in seconds

  @HiveField(5)
  int pointsEarned;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  DateTime lastAccessed;

  @HiveField(8)
  int watchTime; // for videos, in seconds

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.contentId,
    this.progressPercentage = 0.0,
    this.timeSpent = 0,
    this.pointsEarned = 0,
    this.completedAt,
    required this.lastAccessed,
    this.watchTime = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => progressPercentage >= 100.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'progressPercentage': progressPercentage,
      'timeSpent': timeSpent,
      'pointsEarned': pointsEarned,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
      'watchTime': watchTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      userId: json['userId'],
      contentId: json['contentId'],
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
      timeSpent: json['timeSpent'] ?? 0,
      pointsEarned: json['pointsEarned'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(json['lastAccessed']),
      watchTime: json['watchTime'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 14)
class QuizAttempt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String contentId;

  @HiveField(3)
  double score;

  @HiveField(4)
  double maxScore;

  @HiveField(5)
  Map<String, String> answers; // questionId -> answerId

  @HiveField(6)
  int timeTaken; // in seconds

  @HiveField(7)
  DateTime completedAt;

  @HiveField(8)
  int attemptNumber;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.score,
    required this.maxScore,
    required this.answers,
    required this.timeTaken,
    required this.completedAt,
    this.attemptNumber = 1,
  });

  double get percentage => (score / maxScore) * 100;
  bool get isPassed => percentage >= 70; // 70% pass rate

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'score': score,
      'maxScore': maxScore,
      'answers': answers,
      'timeTaken': timeTaken,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'attemptNumber': attemptNumber,
    };
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      userId: json['userId'],
      contentId: json['contentId'],
      score: json['score']?.toDouble() ?? 0.0,
      maxScore: json['maxScore']?.toDouble() ?? 0.0,
      answers: Map<String, String>.from(json['answers'] ?? {}),
      timeTaken: json['timeTaken'] ?? 0,
      completedAt: DateTime.fromMillisecondsSinceEpoch(json['completedAt']),
      attemptNumber: json['attemptNumber'] ?? 1,
    );
  }
}

@HiveType(typeId: 15)
class LearningPlan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> contentIds;

  @HiveField(4)
  List<String> targetDiabetesTypes;

  @HiveField(5)
  List<String> targetTreatments;

  @HiveField(6)
  int estimatedDuration; // in hours

  @HiveField(7)
  int difficulty; // 1-5 scale

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String createdBy;

  LearningPlan({
    required this.id,
    required this.title,
    required this.description,
    this.contentIds = const [],
    this.targetDiabetesTypes = const [],
    this.targetTreatments = const [],
    this.estimatedDuration = 0,
    this.difficulty = 1,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contentIds': contentIds,
      'targetDiabetesTypes': targetDiabetesTypes,
      'targetTreatments': targetTreatments,
      'estimatedDuration': estimatedDuration,
      'difficulty': difficulty,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
    };
  }

  factory LearningPlan.fromJson(Map<String, dynamic> json) {
    return LearningPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      contentIds: List<String>.from(json['contentIds'] ?? []),
      targetDiabetesTypes: List<String>.from(json['targetDiabetesTypes'] ?? []),
      targetTreatments: List<String>.from(json['targetTreatments'] ?? []),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      difficulty: json['difficulty'] ?? 1,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }
}

@HiveType(typeId: 16)
class UserPlanAssignment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String planId;

  @HiveField(3)
  DateTime assignedAt;

  @HiveField(4)
  DateTime? startedAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  double progressPercentage;

  @HiveField(7)
  bool isActive;

  UserPlanAssignment({
    required this.id,
    required this.userId,
    required this.planId,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.progressPercentage = 0.0,
    this.isActive = true,
  });

  bool get isCompleted => progressPercentage >= 100.0;
  bool get isStarted => startedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'assignedAt': assignedAt.millisecondsSinceEpoch,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'progressPercentage': progressPercentage,
      'isActive': isActive,
    };
  }

  factory UserPlanAssignment.fromJson(Map<String, dynamic> json) {
    return UserPlanAssignment(
      id: json['id'],
      userId: json['userId'],
      planId: json['planId'],
      assignedAt: DateTime.fromMillisecondsSinceEpoch(json['assignedAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      progressPercentage: json['progressPercentage']?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }
}

@HiveType(typeId: 17)
class ProgressStats extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  int totalPointsEarned;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime? lastActiveDate;

  @HiveField(5)
  int totalLessonsCompleted;

  @HiveField(6)
  int totalQuizzesCompleted;

  @HiveField(7)
  int totalTimeSpent; // in minutes

  @HiveField(8)
  List<String> badgesEarned;

  @HiveField(9)
  DateTime updatedAt;

  ProgressStats({
    required this.userId,
    this.totalPointsEarned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.totalLessonsCompleted = 0,
    this.totalQuizzesCompleted = 0,
    this.totalTimeSpent = 0,
    this.badgesEarned = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPointsEarned': totalPointsEarned,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.millisecondsSinceEpoch,
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'totalTimeSpent': totalTimeSpent,
      'badgesEarned': badgesEarned,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      userId: json['userId'],
      totalPointsEarned: json['totalPointsEarned'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActiveDate'])
          : null,
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      totalQuizzesCompleted: json['totalQuizzesCompleted'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      badgesEarned: List<String>.from(json['badgesEarned'] ?? []),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }
}