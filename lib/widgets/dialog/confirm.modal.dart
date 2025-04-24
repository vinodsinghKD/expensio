import 'package:expensio/theme/colors.dart';
import 'package:expensio/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class ConfirmModal extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmModal({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      insetPadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: ThemeColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: content,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: "Cancel",
                onPressed: onCancel,
                color: theme.colorScheme.primary,
                type: AppButtonType.outlined,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: AppButton(
                label: "Confirm",
                onPressed: onConfirm,
                color: ThemeColors.error,
              ),
            ),
          ],
        )
      ],
    );
  }

  static showConfirmDialog(
      BuildContext context, {
        required String title,
        required Widget content,
        required VoidCallback onConfirm,
        required VoidCallback onCancel,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmModal(
          title: title,
          content: content,
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
    );
  }
}