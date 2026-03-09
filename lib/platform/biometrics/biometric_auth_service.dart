import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<bool> isAvailable() async {
    final supported = await _localAuth.isDeviceSupported();
    final canCheck = await _localAuth.canCheckBiometrics;
    return supported || canCheck;
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: '使用 Face ID / Touch ID 解锁 DoggyLog',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
