import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

// تم حذف استيراد notification_service هنا

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _title;
  late String _description;
  late String _priority;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // إذا كنا نعدل مهمة، نأخذ بياناتها، وإلا نضع قيم افتراضية
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'Medium';
    _selectedDateTime = widget.task?.dateTime ?? DateTime.now().add(const Duration(minutes: 10));
    // تم حذف متغير _enableNotification هنا
  }

  // دالة لاختيار التاريخ والوقت
  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final taskBox = Hive.box<Task>('tasks_box');

      if (widget.task == null) {
        // إنشاء مهمة جديدة
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _title,
          description: _description,
          dateTime: _selectedDateTime,
          priority: _priority,
        );
        
        await taskBox.add(newTask);
        // تم حذف منطق برمجة التنبيه الجديد هنا
      } else {
        // تحديث مهمة موجودة
        widget.task!.title = _title;
        widget.task!.description = _description;
        widget.task!.priority = _priority;
        widget.task!.dateTime = _selectedDateTime;
        
        await widget.task!.save();
        // تم حذف منطق تحديث أو إلغاء التنبيه هنا
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "إضافة مهمة جديدة" : "تعديل المهمة"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // العنوان
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: "عنوان المهمة",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "يرجى إدخال العنوان" : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 15),
              
              // الوصف
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: "الوصف (اختياري)",
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val!,
              ),
              const SizedBox(height: 15),

              // الأولوية
              DropdownButtonFormField(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: "مستوى الأولوية",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: ['Low', 'Medium', 'High'].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) => setState(() => _priority = val.toString()),
              ),
              const SizedBox(height: 15),

              // اختيار التاريخ والوقت
              ListTile(
                tileColor: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.calendar_month, color: Colors.blue),
                title: const Text("موعد المهمة"),
                subtitle: Text(DateFormat('yyyy-MM-dd | hh:mm a').format(_selectedDateTime)),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: _pickDateTime,
              ),
              
              // تم حذف SwitchListTile الخاص بالتنبيهات من هنا
              
              const SizedBox(height: 30),

              // زر الحفظ
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveTask,
                  child: Text(widget.task == null ? "إضافة المهمة" : "حفظ التعديلات"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}