import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل المهمة"),
        actions: [
          // زر الانتقال لشاشة التعديل
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                ),
              );
            },
          ),
          // زر الحذف
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem("العنوان", task.title, Icons.title),
            const Divider(),
            _buildDetailItem("الوصف", task.description.isEmpty ? "لا يوجد وصف" : task.description, Icons.description),
            const Divider(),
            _buildDetailItem(
              "التاريخ والوقت",
              DateFormat('yyyy-MM-dd   hh:mm a').format(task.dateTime),
              Icons.calendar_today,
            ),
            const Divider(),
            _buildDetailItem("الأولوية", task.priority, Icons.priority_high, 
                color: _getPriorityColor(task.priority)),
            const Divider(),
            _buildDetailItem(
              "الحالة",
              task.isCompleted ? "مكتملة" : "قيد التنفيذ",
              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // ودجت مخصصة لعرض بنود التفاصيل بشكل متناسق
  Widget _buildDetailItem(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.blueGrey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المهمة"),
        content: const Text("هل أنت متأكد من رغبتك في حذف هذه المهمة؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              task.delete(); // حذف من Hive
              Navigator.pop(ctx); // إغلاق الديالوج
              Navigator.pop(context); // العودة للشاشة الرئيسية
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}