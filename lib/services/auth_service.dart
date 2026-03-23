import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  // فحص هل الجهاز يدعم البصمة أو FaceID
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  // تنفيذ عملية التحقق
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك للدخول إلى المهام',
        options: const AuthenticationOptions(
          stickyAuth: true, // يبقى التطبيق يحاول التحقق إذا خرج المستخدم ورجع
          biometricOnly: false, // يسمح باستخدام رمز القفل (PIN) إذا فشلت البصمة
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}