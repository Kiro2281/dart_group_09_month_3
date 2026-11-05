import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future <void> showAppSnackBar( {
  required String text,
  Color? backgroundColor,
  IconData? icon,
  VoidCallback? onRetry,
  String retryText = "Повторить",
}) async {
  final messenger = scaffoldMessengerKey.currentState;

  if (messenger == null) {
    return;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
      action: onRetry == null
          ? null
          : SnackBarAction(
              label: retryText,
              onPressed: onRetry,
              textColor: Colors.white,
            ),
    ),
  );
  }