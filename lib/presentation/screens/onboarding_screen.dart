import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mood_tracker/constant/app_colors.dart';

import '../../data/sources/local_database.dart';
import '../controllers/mood_controller.dart';
import 'main_shell.dart';

/// Multi-step onboarding flow with optional first mood logging.
///
/// Side effects:
/// - Persists onboarding step progress.
/// - Marks onboarding completion in local storage.
/// - Optionally creates first mood entry.
class OnboardingScreen extends StatefulWidget {
  /// Creates onboarding flow screen.
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _database = Get.find<LocalDatabase>();
  final _moodController = Get.find<MoodController>();
  final _pageController = PageController();
  final _currentPage = 0.obs;

  @override
  void initState() {
    super.initState();
    _currentPage.value = _database.onboardingScreen.clamp(0, 3);
    _database.startOnboarding();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage.value);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          _currentPage.value = page;
          _database.saveOnboardingScreen(page);
        },
        children: [
          _IntroPage(
            animation: 'assets/animation/waving_hand.json',
            title: 'Welcome to LUMINA',
            subtitle: 'Your personal mental health companion',
            buttonText: 'Get Started',
            onNext: _nextPage,
          ),
          _InfoPage(
            currentStep: 0,
            animation: 'assets/animation/meditation.json',
            title: 'Why Track Your Mood?',
            items: const [
              'Understand your emotional patterns',
              'Identify triggers and improvements',
              'Build consistent habit',
            ],
            onNext: _nextPage,
            onSkip: _goToFirstMood,
          ),
          _InfoPage(
            currentStep: 1,
            animation: 'assets/animation/daily_activity.json',
            title: 'How It Works',
            items: const [
              'Select your mood emoji',
              'Add optional notes',
              'View your mood history & patterns',
            ],
            footer: 'Your insights, your journey',
            onNext: _nextPage,
            onSkip: _completeWithoutMood,
          ),
          _FirstMoodPage(
            moodController: _moodController,
            onComplete: _completeWithMood,
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    final nextPage = (_currentPage.value + 1).clamp(0, 3);
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToFirstMood() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeWithMood() async {
    HapticFeedback.mediumImpact();
    await _moodController.saveMood(
      title: 'Awesome!',
      message: "Let's start tracking",
    );
    await _database.completeOnboarding();

    Get.off(
      () => const MainShell(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 450),
    );
  }

  Future<void> _completeWithoutMood() async {
    await _database.completeOnboarding();

    Get.off(
      () => const MainShell(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 450),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.animation,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onNext,
  });

  final String animation;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.07),
          Text(
            'LUMINA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 6),
          const Text('😊', style: TextStyle(fontSize: 42)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Lottie.asset(animation, height: 220, repeat: true),
          const SizedBox(height: 24),
          _AnimatedText(title: title, subtitle: subtitle),
          const Spacer(),
          _PrimaryButton(text: buttonText, onPressed: onNext),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.currentStep,
    required this.animation,
    required this.title,
    required this.items,
    required this.onNext,
    required this.onSkip,
    this.footer,
  });

  final int currentStep;
  final String animation;
  final String title;
  final List<String> items;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _StepIndicator(currentStep: currentStep),
          const Spacer(),
          Lottie.asset(animation, height: 220, repeat: true),
          const SizedBox(height: 24),
          _AnimatedText(title: title),
          const SizedBox(height: 18),
          ...items.map((item) => _BenefitItem(text: item)),
          if (footer != null) ...[
            const SizedBox(height: 12),
            Text(
              footer!,
              style: const TextStyle(
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(child: _PrimaryButton(text: 'Next', onPressed: onNext)),
              const SizedBox(width: 12),
              Expanded(child: _SecondaryButton(text: 'Skip', onPressed: onSkip)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FirstMoodPage extends StatelessWidget {
  const _FirstMoodPage({
    required this.moodController,
    required this.onComplete,
  });

  final MoodController moodController;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Text(
            'How are you feeling today?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.18),
          const Spacer(),
          Lottie.asset('assets/animation/first mood.json', height: 280, repeat: true),
          const SizedBox(height: 28),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: moodController.moods.map((option) {
                final selected = moodController.selectedMood.value == option.value;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    moodController.selectMood(option);
                  },
                  child: AnimatedScale(
                    scale: selected ? 1.28 : 0.95,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? option.color.withValues(alpha: 0.24)
                            : AppColors.paper,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? option.color : AppColors.line,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        option.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: moodController.notesController,
            maxLines: 4,
            maxLength: 180,
            decoration: InputDecoration(
              hintText: 'Optional notes',
              filled: true,
              fillColor: AppColors.paper,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const Spacer(),
          _PrimaryButton(text: "Let's Go!", onPressed: onComplete),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MoodColors.sad.withValues(alpha: 0.15),
            MoodColors.neutral.withValues(alpha: 0.15),
            MoodColors.happy.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _AnimatedText extends StatelessWidget {
  const _AnimatedText({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.18),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkSoft,
                ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index <= currentStep;

        return AnimatedContainer(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.line,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
