import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/life/life_rules.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';

import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/section_label.dart';
import '../../decks/providers/deck_filter_provider.dart';
import '../domain/life_game.dart';
import '../providers/life_counter_provider.dart';
import '../providers/round_timer_provider.dart';

/// Life totals for the game being played, plus the odds and ends a match needs:
/// a die, a coin, a round clock and a log of what happened.
///
/// Nothing here is written to the database. It is the app's only screen that
/// exists for the twenty minutes a game lasts and not for the record it leaves.
class LifeCounterScreen extends ConsumerWidget {
  const LifeCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(lifeCounterProvider);

    return game == null ? const _Setup() : _Table(game: game);
  }
}

/// Game and starting total, asked once before the counter opens.
class _Setup extends ConsumerStatefulWidget {
  const _Setup();

  @override
  ConsumerState<_Setup> createState() => _SetupState();
}

class _SetupState extends ConsumerState<_Setup> {
  late String _gameId;
  late TextEditingController _life;

  @override
  void initState() {
    super.initState();
    _gameId = ref.read(deckFilterProvider).gameId;
    _life = TextEditingController(
      text: '${LifeRules.startingLifeFor(_gameId)}',
    );
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  void _selectGame(String gameId) {
    setState(() {
      _gameId = gameId;
      // The other game's total is meaningless here: 20 life in Yu-Gi-Oh! is a
      // typo, not a house rule.
      _life.text = '${LifeRules.startingLifeFor(gameId)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];
    final starting = int.tryParse(_life.text.trim()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lifeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32).clearingFloatingBar,
        children: [
          Text(
            l10n.lifeSetupHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (games.isNotEmpty) ...[
            SectionLabel(l10n.deckGame),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                for (final game in games)
                  ButtonSegment(
                    value: game.id,
                    label: Text(
                      l10n.gameName(game.id, game.name),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              selected: {_gameId},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => _selectGame(selection.first),
            ),
            const SizedBox(height: 24),
          ],
          SectionLabel(l10n.lifeStartingLife),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in LifeRules.presetsFor(_gameId))
                ChoiceChip(
                  label: Text('$preset'),
                  selected: starting == preset,
                  onSelected: (_) => setState(() => _life.text = '$preset'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _life,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: starting <= 0
                ? null
                : () => ref
                      .read(lifeCounterProvider.notifier)
                      .start(gameId: _gameId, startingLife: starting),
            child: Text(l10n.lifeStart),
          ),
        ],
      ),
    );
  }
}

/// The counter itself: two seats facing each other across the phone.
class _Table extends ConsumerStatefulWidget {
  const _Table({required this.game});

  final LifeGame game;

  @override
  ConsumerState<_Table> createState() => _TableState();
}

class _TableState extends ConsumerState<_Table> {
  int? _step;

  int get _currentStep => _step ?? LifeRules.defaultStepFor(widget.game.gameId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = widget.game;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lifeTitle),
        actions: [
          const _TimerButton(),
          IconButton(
            tooltip: l10n.lifeUndo,
            icon: const Icon(Icons.undo),
            onPressed: ref.read(lifeCounterProvider.notifier).undo,
          ),
          PopupMenuButton<_TableAction>(
            onSelected: (action) => _handle(context, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _TableAction.history,
                child: Text(l10n.lifeHistory),
              ),
              PopupMenuItem(
                value: _TableAction.restart,
                child: Text(l10n.lifeRestart),
              ),
              PopupMenuItem(
                value: _TableAction.setup,
                child: Text(l10n.lifeNewSetup),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Turned to face the other side of the table, which is where the
          // person reading it is sitting.
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: _SeatPanel(
                game: game,
                seat: Seat.opponent,
                step: _currentStep,
              ),
            ),
          ),
          _Toolbar(
            steps: LifeRules.stepsFor(game.gameId),
            step: _currentStep,
            onStep: (step) => setState(() => _step = step),
          ),
          Expanded(
            child: _SeatPanel(game: game, seat: Seat.me, step: _currentStep),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(BuildContext context, _TableAction action) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(lifeCounterProvider.notifier);

    switch (action) {
      case _TableAction.history:
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => const _HistorySheet(),
        );

      case _TableAction.restart:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.lifeRestart),
            content: Text(l10n.lifeRestartConfirm(widget.game.startingLife)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.lifeRestart),
              ),
            ],
          ),
        );
        if (confirmed ?? false) notifier.restart();

      case _TableAction.setup:
        notifier.clear();
    }
  }
}

enum _TableAction { history, restart, setup }

/// One player's half of the screen.
class _SeatPanel extends ConsumerWidget {
  const _SeatPanel({
    required this.game,
    required this.seat,
    required this.step,
  });

  final LifeGame game;
  final Seat seat;
  final int step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(lifeCounterProvider.notifier);
    final state = game.seat(seat);

    final accent = theme.gameAccent(game.gameId);
    final name = seat == Seat.me ? l10n.lifeMe : l10n.lifeOpponent;

    return Container(
      width: double.infinity,
      color: accent.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LifeButton(
                icon: Icons.remove,
                label: '$step',
                onPressed: () => notifier.adjustLife(seat, -step),
              ),
              Flexible(
                child: FittedBox(
                  child: Text(
                    '${state.life}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: state.life <= 0
                          ? theme.appColors.loss
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              _LifeButton(
                icon: Icons.add,
                label: '$step',
                onPressed: () => notifier.adjustLife(seat, step),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _CounterRow(seat: seat, state: state),
        ],
      ),
    );
  }
}

class _LifeButton extends StatelessWidget {
  const _LifeButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          iconSize: 32,
          padding: const EdgeInsets.all(16),
          icon: Icon(icon),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// Counters in play, plus a way to put a new one in play.
class _CounterRow extends ConsumerWidget {
  const _CounterRow({required this.seat, required this.state});

  final Seat seat;
  final SeatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(lifeCounterProvider.notifier);
    final active = state.active;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final entry in active.entries)
          InputChip(
            label: Text('${l10n.counterName(entry.key)} ${entry.value}'),
            onPressed: () => notifier.adjustCounter(seat, entry.key, 1),
            onDeleted: () => notifier.adjustCounter(seat, entry.key, -1),
            deleteIcon: const Icon(Icons.remove, size: 16),
          ),
        PopupMenuButton<CounterKind>(
          tooltip: l10n.lifeCounters,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onSelected: (kind) => notifier.adjustCounter(seat, kind, 1),
          itemBuilder: (context) => [
            for (final kind in CounterKind.values)
              if (!active.containsKey(kind))
                PopupMenuItem(value: kind, child: Text(l10n.counterName(kind))),
          ],
        ),
      ],
    );
  }
}

/// The strip between the two seats: step size, die and coin.
class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.steps,
    required this.step,
    required this.onStep,
  });

  final List<int> steps;
  final int step;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final value in steps)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('$value'),
                          selected: step == value,
                          onSelected: (_) => onStep(value),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.toolCoin,
              icon: const Icon(Icons.monetization_on_outlined),
              onPressed: () => _flipCoin(context, ref),
            ),
            IconButton(
              tooltip: l10n.toolDice,
              icon: const Icon(Icons.casino_outlined),
              onPressed: () => _rollDice(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _flipCoin(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final heads = ref.read(lifeCounterProvider.notifier).flipCoin();

    await _showResult(
      context,
      title: l10n.toolCoin,
      result: heads ? l10n.coinHeads : l10n.coinTails,
    );
  }

  Future<void> _rollDice(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final sides = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(l10n.toolDice),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sides in [4, 6, 8, 10, 12, 20])
                    ActionChip(
                      label: Text('d$sides'),
                      onPressed: () => Navigator.of(context).pop(sides),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (sides == null || !context.mounted) return;

    final value = ref.read(lifeCounterProvider.notifier).rollDice(sides);
    await _showResult(context, title: 'd$sides', result: '$value');
  }

  Future<void> _showResult(
    BuildContext context, {
    required String title,
    required String result,
  }) {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          result,
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).actionClose),
          ),
        ],
      ),
    );
  }
}

/// The round clock, in the app bar because it is worth glancing at without
/// opening anything.
class _TimerButton extends ConsumerWidget {
  const _TimerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timer = ref.watch(roundTimerProvider);

    return TextButton.icon(
      onPressed: () => _openSheet(context, ref),
      icon: Icon(
        timer.running ? Icons.pause_circle_outline : Icons.timer_outlined,
        size: 20,
      ),
      label: Text(
        timer.label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: timer.isOver ? theme.appColors.loss : null,
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final timer = ref.watch(roundTimerProvider);
            final notifier = ref.read(roundTimerProvider.notifier);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(l10n.toolTimer),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      timer.isOver ? l10n.timerOver : timer.label,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionLabel(l10n.timerLength),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final minutes in RoundTimerNotifier.presets)
                        ChoiceChip(
                          label: Text('$minutes'),
                          selected: timer.total.inMinutes == minutes,
                          onSelected: (_) =>
                              notifier.setLength(Duration(minutes: minutes)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: timer.isOver ? null : notifier.toggle,
                          icon: Icon(
                            timer.running ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(
                            timer.running ? l10n.timerPause : l10n.timerStart,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: notifier.reset,
                        child: Text(l10n.timerReset),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Everything that happened this game, newest first.
class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(lifeCounterProvider);
    final log = game?.log.reversed.toList() ?? const <LifeEvent>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(l10n.lifeHistory),
            const SizedBox(height: 12),
            if (log.isEmpty)
              Text(
                l10n.lifeHistoryEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: log.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _HistoryRow(event: log[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.event});

  final LifeEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final (String title, String trailing) = switch (event) {
      LifeChanged(:final seat, :final delta, :final total) => (
        seat == Seat.me ? l10n.lifeMe : l10n.lifeOpponent,
        '${delta > 0 ? '+' : ''}$delta  →  $total',
      ),
      CounterChanged(:final seat, :final kind, :final delta, :final total) => (
        '${seat == Seat.me ? l10n.lifeMe : l10n.lifeOpponent} · '
            '${l10n.counterName(kind)}',
        '${delta > 0 ? '+' : ''}$delta  →  $total',
      ),
      DiceRolled(:final sides, :final value) => ('d$sides', '$value'),
      CoinFlipped(:final heads) => (
        l10n.toolCoin,
        heads ? l10n.coinHeads : l10n.coinTails,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          Text(
            trailing,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
