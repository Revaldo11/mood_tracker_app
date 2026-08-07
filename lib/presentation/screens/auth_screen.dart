import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mood_tracker/constant/app_colors.dart';

import '../controllers/auth_controller.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
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
              AppColors.paper,
              AppColors.paper,
              AppColors.paperDim,
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
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome back. Let’s find your light\nwithin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w400,
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
                      color: AppColors.paper.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: _buildLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.inkSoft,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _controller.loginEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: _controller.validateLoginEmail,
            decoration: InputDecoration(
              hintText: 'example@mail.com',
              filled: true,
              fillColor: AppColors.paperDim,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Password',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.inkSoft,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => TextFormField(
              controller: _controller.loginPasswordController,
              obscureText: _controller.loginObscure.value,
              // validator: _controller.validateLoginPassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.loginObscure.value =
                        !_controller.loginObscure.value;
                  },
                  icon: Icon(
                    _controller.loginObscure.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                filled: true,
                fillColor: AppColors.paperDim,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _controller.isLoginLoading.value
                    ? null
                    : () async {
                        if (!(_loginFormKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        final isSuccess = await _controller.loginOrAutoRegister();
                        if (!isSuccess) {
                          return;
                        }

                        Get.offAll(
                          () => _controller.isOnboardingCompleted
                              ? const MainShell()
                              : const OnboardingScreen(),
                        );
                      },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _controller.isLoginLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Sign In / Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 100),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          // Row(
          //   children: [
          //     const Expanded(child: Divider(color: Color(0xFFE1E8E7))),
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 12),
          //       child: Text(
          //         'or continue with',
          //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //           color: const Color(0xFF8A9492),
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //     const Expanded(child: Divider(color: Color(0xFFE1E8E7))),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // _socialButton('Google', Icons.g_mobiledata),
          // const SizedBox(height: 10),
          // _socialButton('Apple', Icons.apple),
        ],
      ),
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: AppColors.ink, size: 24),
        label: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
