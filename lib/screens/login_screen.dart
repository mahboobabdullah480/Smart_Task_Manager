import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false; // للتبديل بين إنشاء حساب وتسجيل دخول
  final AuthService _authService = AuthService();
  final Box _usersBox = Hive.box('users_box');
  final Box _settingsBox = Hive.box('settings');

  // دالة تسجيل الدخول أو إنشاء الحساب
  void _handleAuth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMsg("يرجى ملء كافة الحقول");
      return;
    }

    if (_isSignUp) {
      // إنشاء حساب جديد
      if (_usersBox.containsKey(email)) {
        _showMsg("هذا البريد مسجل مسبقاً");
      } else {
        await _usersBox.put(email, password);
        await _settingsBox.put('last_user', email); // حفظ آخر مستخدم للبصمة
        _showMsg("تم إنشاء الحساب بنجاح");
        _navigateToHome();
      }
    } else {
      // تسجيل دخول
      String? storedPassword = _usersBox.get(email);
      if (storedPassword == password) {
        await _settingsBox.put('last_user', email);
        _navigateToHome();
      } else {
        _showMsg("البريد أو كلمة المرور غير صحيحة");
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // التحقق إذا كان هناك مستخدم سابق لتفعيل زر البصمة
    String? lastUser = _settingsBox.get('last_user');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.assignment_ind, size: 80, color: Colors.blue),
                const SizedBox(height: 10),
                Text(_isSignUp ? "إنشاء حساب جديد" : "تسجيل الدخول", 
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "البريد الإلكتروني", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "كلمة المرور", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleAuth,
                    child: Text(_isSignUp ? "إنشاء حساب" : "دخول"),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? "لديك حساب بالفعل؟ سجل دخولك" : "ليس لديك حساب؟ أنشئ حساباً الآن"),
                ),
                if (!_isSignUp && lastUser != null) ...[
                  const Divider(),
                  const Text("أو الدخول السريع"),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, size: 60, color: Colors.green),
                    onPressed: () async {
                      bool auth = await _authService.authenticate();
                      if (auth) _navigateToHome();
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}