import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import 'add_edit_task_screen.dart';
import 'task_details_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الوصول إلى صندوق المهام المخزنة
    final Box<Task> taskBox = Hive.box<Task>('tasks_box');

    return Scaffold(
      appBar: AppBar(
        title: const Text("مهامي اليومية"),
        centerTitle: true,
        // إضافة زر الانتقال للإعدادات في الشريط العلوي
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      // استخدام ValueListenableBuilder لتحديث القائمة تلقائياً عند أي تغيير في Hive
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("لا توجد مهام حالياً، ابدأ بإضافة واحدة!", 
                       style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // عرض المهام في قائمة مرتبة
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              Task? task = box.getAt(index);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPriorityColor(task!.priority),
                    child: const Icon(Icons.assignment, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // وضع خط على النص إذا كانت المهمة مكتملة
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // الانتقال لشاشة التفاصيل عند النقر
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: task),
                      ),
                    );
                  },
                  // تغيير حالة المهمة (مكتملة/غير مكتملة)
                  trailing: Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      task.isCompleted = value!;
                      task.save(); // حفظ التعديل في Hive مباشرة
                    },
                  ),
                  // حذف المهمة عند الضغط المطول
                  onLongPress: () => _confirmDelete(context, task),
                ),
              );
            },
          );
        },
      ),
      // زر إضافة مهمة جديدة
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // دالة مساعدة لتحديد لون الأولوية
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.redAccent;
      case 'Medium': return Colors.orangeAccent;
      case 'Low': return Colors.greenAccent;
      default: return Colors.blueGrey;
    }
  }

  // ديالوج تأكيد الحذف عند الضغط المطول
  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المهمة"),
        content: Text("هل أنت متأكد من حذف '${task.title}'؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              task.delete(); // الحذف من صندوق Hive
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}