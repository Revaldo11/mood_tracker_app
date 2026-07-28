import 'package:bcrypt/bcrypt.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mood_tracker/constant.dart';
import 'package:uuid/uuid.dart';

import '../../data/sources/local_database.dart';
import '../../domain/models/user_profile.dart';

class AuthController extends GetxController {
  AuthController(this._database);

  final LocalDatabase _database;
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerUsernameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();

  final loginObscure = true.obs;
  final registerPasswordObscure = true.obs;
  final registerConfirmPasswordObscure = true.obs;
  final isLoginLoading = false.obs;
  final isRegisterLoading = false.obs;
  final termsAccepted = false.obs;
  final registerPasswordValue = ''.obs;

  UserProfile? get currentUser => _database.currentUser;
  bool get isOnboardingCompleted => _database.isOnboardingCompleted;

  String? validateLoginEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!EmailValidator.validate(email)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? validateLoginPassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (!_isStrongPassword(password)) {
      return 'Password terlalu lemah. Min 6 chars, 1 uppercase, 1 number.';
    }
    return null;
  }

  String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) {
      return 'Username wajib diisi.';
    }
    if (username.length < 3 || username.length > 30) {
      return 'Username harus 3-30 karakter.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username hanya boleh huruf, angka, underscore.';
    }
    return null;
  }

  String? validateRegisterEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!EmailValidator.validate(email)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? validateRegisterPassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (!_isStrongPassword(password)) {
      return 'Password terlalu lemah. Min 6 chars, 1 uppercase, 1 number.';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (confirmPassword != registerPasswordController.text.trim()) {
      return 'Konfirmasi password tidak sesuai.';
    }
    return null;
  }

  double get passwordStrength {
    final password = registerPasswordValue.value.trim();
    if (password.isEmpty) {
      return 0;
    }

    var score = 0;
    if (password.length >= 6) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;

    return score / 3;
  }

  String get passwordStrengthLabel {
    final strength = passwordStrength;
    if (strength <= 0.33) {
      return 'Weak';
    }
    if (strength <= 0.66) {
      return 'Fair';
    }
    return 'Strong';
  }

  Color get passwordStrengthColor {
    final strength = passwordStrength;
    if (strength <= 0.33) {
      return const Color(0xFFFF6B6B);
    }
    if (strength <= 0.66) {
      return const Color(0xFFFFA500);
    }
    return const Color(0xFF6BCB77);
  }

  Future<bool> login() async {
    if (isLoginLoading.value) {
      return false;
    }

    isLoginLoading.value = true;
    try {
      final email = loginEmailController.text.trim().toLowerCase();
      final password = loginPasswordController.text;
      final user = _findUserByEmail(email);
      if (user == null || !BCrypt.checkpw(password, user.passwordHash)) {
        Get.snackbar(
          'Login Gagal',
          'Email atau password salah.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
        return false;
      }

      await _database.setCurrentUserId(user.id);
      Get.snackbar(
        'Berhasil',
        'Login berhasil.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return true;
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<bool> loginOrAutoRegister() async {
    if (isLoginLoading.value) {
      return false;
    }

    isLoginLoading.value = true;
    try {
      final email = loginEmailController.text.trim().toLowerCase();
      final password = loginPasswordController.text;
      final existingUser = _findUserByEmail(email);

      if (existingUser == null) {
        final username = _buildAutoUsername(email);
        final newUser = UserProfile(
          id: const Uuid().v4(),
          username: username,
          email: email,
          passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
          createdAt: DateTime.now(),
        );

        logger.w(newUser);

        await _database.registerUser(newUser);
        await _database.clearOnboardingProgress();
        await _database.saveOnboardingCompleted(false);

        Get.snackbar(
          'Berhasil',
          'Akun baru berhasil dibuat.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
        return true;
      }

      if (!BCrypt.checkpw(password, existingUser.passwordHash)) {
        Get.snackbar(
          'Login Gagal',
          'Email atau password salah.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
        return false;
      }

      await _database.setCurrentUserId(existingUser.id);
      Get.snackbar(
        'Berhasil',
        'Login berhasil.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return true;
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<bool> register() async {
    if (isRegisterLoading.value) {
      return false;
    }

    isRegisterLoading.value = true;
    try {
      final username = registerUsernameController.text.trim();
      final email = registerEmailController.text.trim().toLowerCase();
      final password = registerPasswordController.text;

      if (_findUserByEmail(email) != null) {
        Get.snackbar(
          'Register Gagal',
          'Email sudah terdaftar. Silakan login.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
        return false;
      }

      if (_findUserByUsername(username) != null) {
        Get.snackbar(
          'Register Gagal',
          'Username sudah digunakan. Pilih username lain.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
        return false;
      }

      final user = UserProfile(
        id: const Uuid().v4(),
        username: username,
        email: email,
        passwordHash: BCrypt.hashpw(password, BCrypt.gensalt()),
        createdAt: DateTime.now(),
      );

      await _database.registerUser(user);
      await _database.clearOnboardingProgress();

      Get.snackbar(
        'Berhasil',
        'Akun berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return true;
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _database.clearCurrentUserId();

    loginEmailController.clear();
    loginPasswordController.clear();
    registerUsernameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();

    loginObscure.value = true;
  }

  UserProfile? _findUserByEmail(String username) {
    for (final user in _database.users) {
      if (user.username.toLowerCase() == username) {
        return user;
      }
    }
    return null;
  }

  UserProfile? _findUserByUsername(String username) {
    for (final user in _database.users) {
      if (user.username.toLowerCase() == username.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  bool _isStrongPassword(String password) {
    return password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  String _buildAutoUsername(String email) {
    final localPart = email.split('@').first;
    final cleaned = localPart.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    var username = cleaned.isEmpty ? 'user' : cleaned;

    if (username.length < 3) {
      username = '${username}user';
    }

    if (username.length > 30) {
      username = username.substring(0, 30);
    }

    var finalUsername = username;
    var counter = 1;
    while (_findUserByUsername(finalUsername) != null) {
      final suffix = '_$counter';
      final maxLength = 30 - suffix.length;
      final base = username.length > maxLength
          ? username.substring(0, maxLength)
          : username;
      finalUsername = '$base$suffix';
      counter++;
    }

    return finalUsername;
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerUsernameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }
}
