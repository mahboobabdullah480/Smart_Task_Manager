import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_screen.dart';
import '../models/task_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box _settingsBox = Hive.box('settings');
  final Box _usersBox = Hive.box('users_box');
  final Box<Task> _taskBox = Hive.box<Task>('tasks_box');

  @override
  Widget build(BuildContext context) {
    String? currentUser = _settingsBox.get('last_user', defaultValue: "مستخدم عام");

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // قسم الحساب
          const _SectionHeader(title: "الحساب"),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("المستخدم الحالي"),
            subtitle: Text(currentUser!),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("تسجيل الخروج"),
            onTap: () => _logout(context),
          ),

          const Divider(),

          // داخل ملف settings_screen.dart في قائمة الـ ListView

SwitchListTile(
  secondary: Icon(
    _settingsBox.get('darkMode', defaultValue: false) 
        ? Icons.dark_mode 
        : Icons.light_mode,
    color: Colors.amber,
  ),
  title: const Text("الوضع الليلي"),
  subtitle: const Text("تغيير مظهر التطبيق للوضع المظلم"),
  value: _settingsBox.get('darkMode', defaultValue: false),
  onChanged: (bool value) {
    // حفظ الخيار في Hive وسيتم تحديث التطبيق كاملاً فوراً
    _settingsBox.put('darkMode', value);
  },
),

          // قسم الأمان
          const _SectionHeader(title: "الأمان والخصوصية"),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: Colors.green),
            title: const Text("تفعيل تسجيل الدخول بالبصمة"),
            subtitle: const Text("السماح بالدخول السريع للجلسات القادمة"),
            value: _settingsBox.get('biometric_enabled', defaultValue: true),
            onChanged: (bool value) {
              setState(() {
                _settingsBox.put('biometric_enabled', value);
              });
            },
          ),

          const Divider(),

          // قسم البيانات
          const _SectionHeader(title: "إدارة البيانات"),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.orange),
            title: const Text("مسح كافة المهام"),
            subtitle: const Text("سيتم حذف جميع المهام المخزنة محلياً"),
            onTap: () => _confirmClearData(context),
          ),

          const Divider(),

          // حول التطبيق
          const _SectionHeader(title: "حول"),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("إصدار التطبيق"),
            trailing: Text("1.0.0"),
          ),
        ],
      ),
    );
  }

  // دالة تسجيل الخروج
  void _logout(BuildContext context) {
    // يمكن مسح 'last_user' إذا أردت إجبار المستخدم على كتابة البريد في كل مرة
    // _settingsBox.delete('last_user'); 
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // دالة تأكيد مسح البيانات
  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تحذير!"),
        content: const Text("هل أنت متأكد من حذف جميع المهام؟ لا يمكن التراجع عن هذا الإجراء."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await _taskBox.clear();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم مسح البيانات بنجاح")),
                );
              }
            },
            child: const Text("حذف الكل", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ودجت صغيرة لتنسيق عناوين الأقسام
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}