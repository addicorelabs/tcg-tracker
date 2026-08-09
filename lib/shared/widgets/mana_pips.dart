import 'package:flutter/material.dart';

/// The five Magic colours, in the order the game itself always lists them.
enum ManaColor {
  white('W', Color(0xFFF6F2C8)),
  blue('U', Color(0xFF9FC4E8)),
  black('B', Color(0xFF9A8F8A)),
  red('R', Color(0xFFE58E72)),
  green('G', Color(0xFF8FBF8C));

  const ManaColor(this.code, this.color);

  /// Single letter used in colour identity strings such as "UR".
  final String code;
  final Color color;

  static ManaColor? fromCode(String code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }

  /// Parses a colour identity string, ignoring anything unrecognised and
  /// keeping the canonical WUBRG order rather than the order typed.
  static List<ManaColor> parse(String? identity) {
    if (identity == null) return const [];

    final codes = identity.toUpperCase().split('');
    return [
      for (final value in values)
        if (codes.contains(value.code)) value,
    ];
  }

  static String encode(Iterable<ManaColor> colors) {
    return [
      for (final value in values)
        if (colors.contains(value)) value.code,
    ].join();
  }
}

/// Row of coloured dots standing in for a deck's colour identity.
class ManaPips extends StatelessWidget {
  const ManaPips(this.identity, {this.size = 10, super.key});

  final String? identity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = ManaColor.parse(identity);
    if (colors.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in colors)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.25)),
              ),
            ),
          ),
      ],
    );
  }
}
