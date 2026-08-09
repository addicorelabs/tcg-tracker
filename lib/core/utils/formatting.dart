/// Winrate as a whole-number percentage, or null when there is nothing yet.
///
/// Null propagates on purpose: a missing winrate has to reach the widget as
/// null so it can be drawn as a dash. Rounding it to "0%" here would turn "no
/// matches" into "never won", which is a different statement.
String? winratePercent(double? winrate) =>
    winrate == null ? null : '${(winrate * 100).round()}%';

/// A difference between two winrates, in percentage points, always signed.
///
/// The sign is the point: without it, "7 points" reads the same whether going
/// first helped or hurt.
String percentagePoints(double difference) {
  final points = (difference * 100).round();
  return points >= 0 ? '+$points' : '$points';
}
