import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mood_tracker/presentation/controllers/mood_controller.dart';

class DataWarningDialog extends StatelessWidget {
  const DataWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoodController>();
    final RxBool dontShowAgain = false.obs;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            _buildDivider(),
            _buildWarningSection(),
            _buildDivider(),
            _buildTipSection(context),
            _buildCheckbox(dontShowAgain),
            _buildButton(context, controller, dontShowAgain),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Lottie.asset(
            'assets/animation/warning_circle.json',
            height: 35,
            repeat: true,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Data Stored Locally',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'All your mood data is saved on this device only.',
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        height: 0.5,
        color: Get.theme.dividerColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important:',
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildWarningList(),
        ],
      ),
    );
  }

  Widget _buildWarningList() {
    final items = [
      'No cloud backup',
      'Uninstalling app = data lost',
      'Clearing app data = data lost',
      'Device reset = data lost',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                '• $item',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTipSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber)
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          '💡 Tip: Regular export of your data to email or cloud storage for safety',
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(RxBool dontShowAgain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        children: [
          Obx(
            () => Checkbox(
              value: dontShowAgain.value,
              onChanged: (value) {
                dontShowAgain.value = value ?? false;
              },
            ),
          ),
          Text(
            'Don\'t show this again',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    MoodController controller,
    RxBool dontShowAgain,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () async {
            // Mark as shown
            await controller.markDataWarningAsShown();

            // Close dialog
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BCB77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Understood',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
