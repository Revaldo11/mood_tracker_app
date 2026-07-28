import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import 'onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final _controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9FBFA),
              Color(0xFFF9FBFA),
              Color(0xFFEFFFF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'LUMINA',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF0D7A70),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Create your account to start\ntracking your mood.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF46514F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 540),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _registerFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _controller.registerUsernameController,
                            validator: _controller.validateUsername,
                            decoration: _registerDecoration(
                              'Username',
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _controller.registerEmailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _controller.validateRegisterEmail,
                            decoration: _registerDecoration(
                              'Email Address',
                              Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => TextFormField(
                              controller: _controller.registerPasswordController,
                              obscureText: _controller.registerPasswordObscure.value,
                              validator: _controller.validateRegisterPassword,
                              onChanged: (value) {
                                _controller.registerPasswordValue.value = value;
                              },
                              decoration: _registerDecoration(
                                'Password',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _controller.registerPasswordObscure.value =
                                        !_controller.registerPasswordObscure.value;
                                  },
                                  icon: Icon(
                                    _controller.registerPasswordObscure.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => TextFormField(
                              controller: _controller.registerConfirmPasswordController,
                              obscureText:
                                  _controller.registerConfirmPasswordObscure.value,
                              validator: _controller.validateConfirmPassword,
                              decoration: _registerDecoration(
                                'Confirm Password',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _controller.registerConfirmPasswordObscure.value =
                                        !_controller.registerConfirmPasswordObscure.value;
                                  },
                                  icon: Icon(
                                    _controller.registerConfirmPasswordObscure.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _controller.passwordStrength,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(8),
                                  color: _controller.passwordStrengthColor,
                                  backgroundColor: const Color(0xFFE4E7EC),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Strength: ${_controller.passwordStrengthLabel}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => CheckboxListTile(
                              value: _controller.termsAccepted.value,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                _controller.termsAccepted.value = value ?? false;
                              },
                              title: const Text('Saya menyetujui Terms & Conditions'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: _controller.isRegisterLoading.value
                                    ? null
                                    : () async {
                                        if (!(_registerFormKey.currentState
                                                ?.validate() ??
                                            false)) {
                                          return;
                                        }

                                        if (!_controller.termsAccepted.value) {
                                          Get.snackbar(
                                            'Register Gagal',
                                            'Harap setujui Terms & Conditions.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            margin: const EdgeInsets.all(16),
                                            borderRadius: 8,
                                          );
                                          return;
                                        }

                                        final isSuccess = await _controller.register();
                                        if (!isSuccess) {
                                          return;
                                        }

                                        Get.offAll(() => const OnboardingScreen());
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D7A70),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _controller.isRegisterLoading.value
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Register',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _registerDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFFCFDFC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7E0DF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF0D7A70),
          width: 1.4,
        ),
      ),
    );
  }
}
