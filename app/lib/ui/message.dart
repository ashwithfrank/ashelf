import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.text, this.action, this.onTap});
  final String text;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onTap, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}
