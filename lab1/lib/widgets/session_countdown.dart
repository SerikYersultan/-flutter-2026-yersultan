import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';

class SessionCountdown extends StatefulWidget {
  const SessionCountdown({
    super.key,
    required this.startsAt,
    this.sessionDuration = const Duration(hours: 1),
  });

  final DateTime startsAt;
  final Duration sessionDuration;

  @override
  State<SessionCountdown> createState() => _SessionCountdownState();
}

class _SessionCountdownState extends State<SessionCountdown> {
  late final Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), _refresh);
  }

  void _refresh(Timer timer) {
    if (!mounted) {
      return;
    }
    final now = DateTime.now();
    setState(() {
      _now = now;
    });
  }

  @override
  void didUpdateWidget(covariant SessionCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startsAt != widget.startsAt ||
        oldWidget.sessionDuration != widget.sessionDuration) {
      _now = DateTime.now();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countdown = countdownAt(
      startsAt: widget.startsAt,
      now: _now,
      sessionDuration: widget.sessionDuration,
    );
    return Text(
      countdownText(countdown),
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}
