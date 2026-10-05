import 'dart:async';

import 'package:flutter/material.dart';

import '../hub_style.dart';

class QuestResetCountdown extends StatefulWidget {
  const QuestResetCountdown({super.key});

  @override
  State<QuestResetCountdown> createState() => _QuestResetCountdownState();
}

class _QuestResetCountdownState extends State<QuestResetCountdown> {
  static const _tickInterval = Duration(seconds: 1);

  Duration _remaining = _untilMidnight();
  Timer? _timer;

  static Duration _untilMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String get _formattedRemaining {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      _tickInterval,
      (_) => setState(() => _remaining = _untilMidnight()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Nouvelles quêtes dans ${_remaining.inHours} heures et '
          '${_remaining.inMinutes.remainder(60)} minutes',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: HubStyle.deepNavy.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: HubStyle.mutedText,
            ),
            const SizedBox(width: 6),
            Text(_formattedRemaining, style: HubStyle.title(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
