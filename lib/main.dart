import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task_model.dart';
import 'screens/splash_screen.dart';
//import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive
  await Hive.initFlutter();
  
  // تسجيل الـ Adapter الذي قمنا بتوليده
  Hive.registerAdapter(TaskAdapter());
  
  await Hive.openBox('users_box'); // لتخزين بيانات المستخدمين (البريد وكلمة المرور)
  // فتح صندوق المهام
  await Hive.openBox<Task>('tasks_box');

  await Hive.openBox('settings');

  // تهيئة التنبيهات
  //await NotificationService().initNotification();

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام ValueListenableBuilder لمراقبة تغيير وضع الثيم
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, widget) {
        final bool isDarkMode = box.get('darkMode', defaultValue: false);

        return MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          // تعريف الثيم الفاتح
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          // تعريف الثيم المظلم
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          // تحديد الوضع الحالي بناءً على القيمة المخزنة
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}