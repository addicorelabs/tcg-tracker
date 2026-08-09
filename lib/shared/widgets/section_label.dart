import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Spaced uppercase label used to open a block of content.
///
/// The recurring typographic accent of the app: it keeps section titles quiet
/// so the numbers underneath stay the loudest element on the screen.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    this.trailing,
    this.optional = false,
    super.key,
  });

  final String text;
  final Widget? trailing;

  /// Marks a field the form will save without. Only the optional fields are
  /// marked, never the required ones: a form where a handful of fields carry a
  /// quiet "optional" reads faster than one where most of them shout
  /// "required".
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = Text.rich(
      TextSpan(
        text: text.toUpperCase(),
        children: [
          if (optional)
            TextSpan(
              text:
                  '  ${AppLocalizations.of(context).fieldOptional.toLowerCase()}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
        ],
      ),
      style: theme.textTheme.labelSmall,
    );

    if (trailing == null) return label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [label, trailing!],
    );
  }
}
