import 'package:flutter/material.dart';

import '../hub_style.dart';

class HubEmptyMessage extends StatelessWidget {
  const HubEmptyMessage({required this.message, required this.icon, super.key});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 40, color: HubStyle.mutedText),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: HubStyle.body(color: HubStyle.mutedText),
          ),
        ],
      ),
    );
  }
}
