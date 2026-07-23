import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../data/sources/local_database.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      final database = Get.find<LocalDatabase>();
      Get.off(
        () => database.isOnboardingCompleted
            ? const MainShell()
            : const OnboardingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 450),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8FFF2),
              Color(0xFFFFF7D5),
              Color(0xFFFFEEF0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 118,
                height: 118,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Text(
                  '😊',
                  style: TextStyle(fontSize: 64),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.08, 1.08),
                    duration: 750.ms,
                    curve: Curves.easeInOutBack,
                  )
                  .rotate(
                    begin: -0.03,
                    end: 0.03,
                    duration: 750.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 24),
              Text(
                'Mood Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2933),
                    ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Track your daily emotional journey',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF637381),
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF6BCB77),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
