import 'package:flutter/material.dart';

import '../hub_style.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Semantics(
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: HubStyle.title(fontSize: 22)),
            if (subtitleText != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitleText,
                style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
