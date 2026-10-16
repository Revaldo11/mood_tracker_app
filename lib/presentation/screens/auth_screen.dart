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
      body: Stack(
        children: [
          Container(color: const Color(0xFFF9FCF7)),
          Positioned(
            top: -100,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFDDF3DC),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            right: -110,
            bottom: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F6E2),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF63),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF63).withValues(alpha: 0.22),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF17231D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Continue your emotional journey with LUMINA.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF718075),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF35613C).withValues(alpha: 0.10),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
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
        ],
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
              color: const Color(0xFF304237),
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
              fillColor: const Color(0xFFF5F9F3),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDE9DC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4CAF63), width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Password',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF304237),
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
                fillColor: const Color(0xFFF5F9F3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDE9DC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4CAF63), width: 1.4),
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
                  backgroundColor: const Color(0xFF4CAF63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                color: const Color(0xFF8A998D),
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
