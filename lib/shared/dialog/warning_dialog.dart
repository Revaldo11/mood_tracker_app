import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showDialogWarning(
  String message, {
  String title = 'Warning',
}) async {
  await Get.dialog<void>(
    AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: Text(title),
      content: SelectableText(message),
      actions: [
        FilledButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
