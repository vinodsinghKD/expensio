import 'package:flutter/material.dart';

class LoadingModal extends StatelessWidget {
  final Widget content;

  const LoadingModal({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(width: 20),
          Expanded(child: content),
        ],
      ),
    );
  }

  static showLoadingDialog(
      BuildContext context, {
        required Widget content,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingModal(content: content);
      },
    );
  }
}
