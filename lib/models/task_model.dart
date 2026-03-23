import 'package:hive/hive.dart';

part 'task_model.g.dart'; // سيتم توليد هذا الملف تلقائياً

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String priority; // (Low, Medium, High)

  @HiveField(6)
  bool enableNotification; // حقل جديد

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    required this.priority,
    this.enableNotification = false, // القيمة الافتراضية
  });
}