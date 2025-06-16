import 'package:hive/hive.dart';

part 'content.g.dart';

@HiveType(typeId: 6)
class ContentItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  ContentType type;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? videoPath;

  @HiveField(6)
  List<Slide>? slides;

  @HiveField(7)
  List<QuizQuestion>? questions;

  @HiveField(8)
  int duration; // in minutes

  @HiveField(9)
  int pointsValue;

  @HiveField(10)
  List<String> tags;

  @HiveField(11)
  int? fileSize;

  @HiveField(12)
  bool isActive;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  String createdBy;

  @HiveField(15)
  String? thumbnailPath;

  @HiveField(16)
  int difficultyLevel; // 1-5 scale

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.videoPath,
    this.slides,
    this.questions,
    this.duration = 0,
    this.pointsValue = 0,
    this.tags = const [],
    this.fileSize,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
    this.thumbnailPath,
    this.difficultyLevel = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
      'videoPath': videoPath,
      'slides': slides?.map((s) => s.toJson()).toList(),
      'questions': questions?.map((q) => q.toJson()).toList(),
      'duration': duration,
      'pointsValue': pointsValue,
      'tags': tags,
      'fileSize': fileSize,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'thumbnailPath': thumbnailPath,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ContentType.values.byName(json['type']),
      category: json['category'],
      videoPath: json['videoPath'],
      slides: (json['slides'] as List<dynamic>?)
          ?.map((s) => Slide.fromJson(s))
          .toList(),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromJson(q))
          .toList(),
      duration: json['duration'] ?? 0,
      pointsValue: json['pointsValue'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      fileSize: json['fileSize'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      createdBy: json['createdBy'],
      thumbnailPath: json['thumbnailPath'],
      difficultyLevel: json['difficultyLevel'] ?? 1,
    );
  }
}

@HiveType(typeId: 7)
enum ContentType {
  @HiveField(0)
  video,
  @HiveField(1)
  slides,
  @HiveField(2)
  quiz,
  @HiveField(3)
  document,
  @HiveField(4)
  audio,
}

@HiveType(typeId: 8)
class Slide extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  int order;

  @HiveField(5)
  SlideType type;

  Slide({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.order = 0,
    this.type = SlideType.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'order': order,
      'type': type.name,
    };
  }

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imagePath: json['imagePath'],
      order: json['order'] ?? 0,
      type: SlideType.values.byName(json['type']),
    );
  }
}

@HiveType(typeId: 9)
enum SlideType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  textImage,
  @HiveField(3)
  bullet,
}

@HiveType(typeId: 10)
class QuizQuestion extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  QuestionType type;

  @HiveField(3)
  List<QuizOption> options;

  @HiveField(4)
  List<String> correctAnswers;

  @HiveField(5)
  String explanation;

  @HiveField(6)
  int points;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  int difficultyLevel;

  @HiveField(9)
  List<String> tags;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    this.correctAnswers = const [],
    this.explanation = '',
    this.points = 10,
    this.imagePath,
    this.difficultyLevel = 1,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.name,
      'options': options.map((o) => o.toJson()).toList(),
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'points': points,
      'imagePath': imagePath,
      'difficultyLevel': difficultyLevel,
      'tags': tags,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      type: QuestionType.values.byName(json['type']),
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => QuizOption.fromJson(o))
              .toList() ??
          [],
      correctAnswers: List<String>.from(json['correctAnswers'] ?? []),
      explanation: json['explanation'] ?? '',
      points: json['points'] ?? 10,
      imagePath: json['imagePath'],
      difficultyLevel: json['difficultyLevel'] ?? 1,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

@HiveType(typeId: 11)
enum QuestionType {
  @HiveField(0)
  multipleChoice,
  @HiveField(1)
  trueFalse,
  @HiveField(2)
  dragDrop,
  @HiveField(3)
  imageBased,
  @HiveField(4)
  scenarioBased,
}

@HiveType(typeId: 12)
class QuizOption extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  int order;

  QuizOption({
    required this.id,
    required this.text,
    this.imagePath,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
      'order': order,
    };
  }

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'],
      text: json['text'],
      imagePath: json['imagePath'],
      order: json['order'] ?? 0,
    );
  }
}