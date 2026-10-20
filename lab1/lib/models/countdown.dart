sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

Countdown countdownAt({
  required DateTime startsAt,
  required DateTime now,
  Duration sessionDuration = const Duration(hours: 1),
}) {
  if (sessionDuration <= Duration.zero) {
    throw ArgumentError.value(
      sessionDuration,
      'sessionDuration',
      'Must be positive',
    );
  }

  if (now.isBefore(startsAt)) {
    return Upcoming(startsAt.difference(now));
  }

  final elapsed = now.difference(startsAt);
  if (elapsed < sessionDuration) {
    return Started(elapsed);
  }

  return const Ended();
}

String countdownText(Countdown countdown) {
  return switch (countdown) {
    Upcoming(:final remaining) => 'Starts in ${_durationText(remaining)}',
    Started(:final elapsed) => 'Started ${_durationText(elapsed)} ago',
    Ended() => 'Ended',
  };
}

String _durationText(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes == 0) {
    return 'less than 1 minute';
  }

  final days = duration.inDays;
  if (days > 0) {
    final hours = duration.inHours.remainder(24);
    return '${days}d ${hours}h';
  }

  final hours = duration.inHours;
  if (hours > 0) {
    return '${hours}h ${minutes.remainder(60)}m';
  }

  return '$minutes min';
}
