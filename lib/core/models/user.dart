import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  String passwordHash;

  @HiveField(4)
  UserRole role;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  MedicalProfile? medicalProfile;

  @HiveField(9)
  LearningPreferences? preferences;

  @HiveField(10)
  List<String> assignedPlans;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    this.role = UserRole.patient,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.medicalProfile,
    this.preferences,
    this.assignedPlans = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'passwordHash': passwordHash,
      'role': role.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'medicalProfile': medicalProfile?.toJson(),
      'preferences': preferences?.toJson(),
      'assignedPlans': assignedPlans,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      passwordHash: json['passwordHash'],
      role: UserRole.values.byName(json['role']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      medicalProfile: json['medicalProfile'] != null
          ? MedicalProfile.fromJson(json['medicalProfile'])
          : null,
      preferences: json['preferences'] != null
          ? LearningPreferences.fromJson(json['preferences'])
          : null,
      assignedPlans: List<String>.from(json['assignedPlans'] ?? []),
    );
  }
}

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  patient,
  @HiveField(1)
  admin,
}

@HiveType(typeId: 2)
class MedicalProfile extends HiveObject {
  @HiveField(0)
  DiabetesType diabetesType;

  @HiveField(1)
  DateTime? diagnosisDate;

  @HiveField(2)
  List<Treatment> treatments;

  @HiveField(3)
  double? hba1c;

  @HiveField(4)
  List<String> complications;

  @HiveField(5)
  String? healthcareProvider;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  MedicalProfile({
    required this.diabetesType,
    this.diagnosisDate,
    this.treatments = const [],
    this.hba1c,
    this.complications = const [],
    this.healthcareProvider,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'diabetesType': diabetesType.name,
      'diagnosisDate': diagnosisDate?.millisecondsSinceEpoch,
      'treatments': treatments.map((t) => t.toJson()).toList(),
      'hba1c': hba1c,
      'complications': complications,
      'healthcareProvider': healthcareProvider,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      diabetesType: DiabetesType.values.byName(json['diabetesType']),
      diagnosisDate: json['diagnosisDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['diagnosisDate'])
          : null,
      treatments: (json['treatments'] as List<dynamic>?)
              ?.map((t) => Treatment.fromJson(t))
              .toList() ??
          [],
      hba1c: json['hba1c']?.toDouble(),
      complications: List<String>.from(json['complications'] ?? []),
      healthcareProvider: json['healthcareProvider'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 3)
enum DiabetesType {
  @HiveField(0)
  type1,
  @HiveField(1)
  type2,
  @HiveField(2)
  gestational,
  @HiveField(3)
  prediabetes,
}

@HiveType(typeId: 4)
class Treatment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? dosage;

  @HiveField(3)
  String? frequency;

  @HiveField(4)
  DateTime? startDate;

  @HiveField(5)
  bool isActive;

  Treatment({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
    this.startDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: json['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startDate'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
}

@HiveType(typeId: 5)
class LearningPreferences extends HiveObject {
  @HiveField(0)
  List<String> preferredContentTypes;

  @HiveField(1)
  int dailyLearningGoalMinutes;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  List<int> reminderTimes;

  @HiveField(4)
  String difficultyLevel;

  LearningPreferences({
    this.preferredContentTypes = const ['video', 'quiz'],
    this.dailyLearningGoalMinutes = 30,
    this.notificationsEnabled = true,
    this.reminderTimes = const [9, 20], // 9 AM and 8 PM
    this.difficultyLevel = 'beginner',
  });

  Map<String, dynamic> toJson() {
    return {
      'preferredContentTypes': preferredContentTypes,
      'dailyLearningGoalMinutes': dailyLearningGoalMinutes,
      'notificationsEnabled': notificationsEnabled,
      'reminderTimes': reminderTimes,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory LearningPreferences.fromJson(Map<String, dynamic> json) {
    return LearningPreferences(
      preferredContentTypes:
          List<String>.from(json['preferredContentTypes'] ?? ['video', 'quiz']),
      dailyLearningGoalMinutes: json['dailyLearningGoalMinutes'] ?? 30,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      reminderTimes: List<int>.from(json['reminderTimes'] ?? [9, 20]),
      difficultyLevel: json['difficultyLevel'] ?? 'beginner',
    );
  }
}