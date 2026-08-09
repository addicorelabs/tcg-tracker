import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A swiss round clock.
@immutable
class RoundTimer {
  const RoundTimer({
    required this.remaining,
    required this.total,
    this.running = false,
  });

  final Duration remaining;
  final Duration total;
  final bool running;

  bool get isOver => remaining <= Duration.zero;

  /// mm:ss, and hh:mm:ss only if a round is ever set past an hour.
  String get label {
    final seconds = remaining.inSeconds.clamp(0, 86400);
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  RoundTimer copyWith({Duration? remaining, Duration? total, bool? running}) {
    return RoundTimer(
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      running: running ?? this.running,
    );
  }
}

/// The round clock, ticking only while it is running.
///
/// The ticker exists only between start and pause: a timer left running behind
/// a paused clock would keep the app awake for nothing.
class RoundTimerNotifier extends Notifier<RoundTimer> {
  /// Fifty minutes is the usual swiss round; the other presets cover the
  /// shorter locals and the longer regionals.
  static const defaultLength = Duration(minutes: 50);
  static const presets = [30, 40, 50, 55, 60];

  Timer? _ticker;

  @override
  RoundTimer build() {
    ref.onDispose(_stopTicking);
    return const RoundTimer(remaining: defaultLength, total: defaultLength);
  }

  void setLength(Duration length) {
    _stopTicking();
    state = RoundTimer(remaining: length, total: length);
  }

  void toggle() => state.running ? pause() : start();

  void start() {
    if (state.running || state.isOver) return;

    state = state.copyWith(running: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _stopTicking();
    state = state.copyWith(running: false);
  }

  void reset() {
    _stopTicking();
    state = RoundTimer(remaining: state.total, total: state.total);
  }

  void _tick() {
    final remaining = state.remaining - const Duration(seconds: 1);

    if (remaining <= Duration.zero) {
      _stopTicking();
      state = state.copyWith(remaining: Duration.zero, running: false);
      return;
    }

    state = state.copyWith(remaining: remaining);
  }

  void _stopTicking() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final roundTimerProvider = NotifierProvider<RoundTimerNotifier, RoundTimer>(
  RoundTimerNotifier.new,
);
