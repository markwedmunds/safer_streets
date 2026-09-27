import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/area_report.dart';
import 'crime_check_state.dart';
import 'crime_check_view_model.dart';

class CrimeCheckPage extends ConsumerStatefulWidget {
  const CrimeCheckPage({super.key});

  @override
  ConsumerState<CrimeCheckPage> createState() => _CrimeCheckPageState();
}

class _CrimeCheckPageState extends ConsumerState<CrimeCheckPage> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Searches, then shows the postcode as it was understood, e.g. `WA1 1UH`.
  void _search(String input) {
    final text =
        ref.read(crimeCheckViewModelProvider.notifier).search(input)?.value ??
        input;
    _field.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crimeCheckViewModelProvider);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = text.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Band(
              color: theme.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Safer Streets',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  Text(
                    'STREET-LEVEL CRIME · ENGLAND, WALES AND NORTHERN IRELAND',
                    style: text.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Is your area getting safer?',
                    style: MediaQuery.sizeOf(context).width < 600
                        ? text.displaySmall
                        : text.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'See how much crime was reported within about a mile of a '
                    'postcode, and whether it went up or down on the month '
                    'before.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enter a postcode',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('For example, WA1 1UH', style: muted),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _field,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            errorText: switch (state) {
                              Idle(invalidInput: true) =>
                                'Enter a full UK postcode',
                              _ => null,
                            },
                          ),
                          onSubmitted: _search,
                          // Stay in the field for the next search on desktop;
                          // on touch, closing the keyboard reveals the results.
                          onEditingComplete: switch (defaultTargetPlatform) {
                            TargetPlatform.android ||
                            TargetPlatform.iOS => null,
                            _ => () {},
                          },
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _search(_field.text),
                        icon: const Icon(Icons.arrow_forward),
                        iconAlignment: IconAlignment.end,
                        label: const Text('Check'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Examples(onSearch: _search),
                ],
              ),
            ),
            if (state is! Idle)
              _Band(
                child: switch (state) {
                  Idle() => const SizedBox.shrink(),
                  Loading() => const Center(child: CircularProgressIndicator()),
                  Results() => _Results(state),
                  NotCovered() => const _Message(
                    Icons.info_outline,
                    "Not covered: this data isn't published for Scotland, "
                    'the Isle of Man or the Channel Islands.',
                  ),
                  NotFound() => const _Message(
                    Icons.search_off,
                    'Postcode not found.',
                  ),
                  Failed() => _Message(
                    Icons.error_outline,
                    state.message,
                    action: FilledButton(
                      onPressed: () => _search(state.postcode.value),
                      child: const Text('Try again'),
                    ),
                  ),
                },
              ),
            const Divider(height: 1),
            _Band(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Crime data from data.police.uk and postcode data from '
                'postcodes.io, under the Open Government Licence v3.0.',
                style: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full width, with its content in a centred column.
class _Band extends StatelessWidget {
  const _Band({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color ?? Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720 + padding.horizontal),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _Examples extends StatelessWidget {
  const _Examples({required this.onSearch});

  final ValueChanged<String> onSearch;

  static const _postcodes = {
    'Warrington': 'WA1 1UH',
    'Cardiff': 'CF10 1EP',
    'Belfast': 'BT1 5GS',
    'Edinburgh': 'EH1 1YZ',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Or try',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        for (final MapEntry(key: place, value: postcode) in _postcodes.entries)
          TextButton(onPressed: () => onSearch(postcode), child: Text(place)),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results(this.results);

  final Results results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = text.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final categories = results.categories;
    final (thisBar, lastBar) = results.bars;
    final comparison = results.comparison;

    final number = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatCount(results.total), style: text.displayLarge),
        Text('crimes reported in ${results.thisMonth}', style: muted),
      ],
    );
    final detail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: results.summary),
              TextSpan(
                text: comparison.change,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _trendColor(theme.colorScheme, results.crime.trend),
                ),
              ),
              TextSpan(text: comparison.rest),
            ],
          ),
          style: text.bodyLarge,
        ),
        const SizedBox(height: 16),
        _MonthBar(
          results.lastMonth,
          results.lastTotal,
          lastBar,
          theme.colorScheme.outline,
        ),
        const SizedBox(height: 8),
        _MonthBar(
          results.thisMonth,
          results.total,
          thisBar,
          theme.colorScheme.primary,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(results.location, style: muted)),
          ],
        ),
        const SizedBox(height: 8),
        Text(results.heading, style: text.headlineMedium),
        const SizedBox(height: 24),
        if (MediaQuery.sizeOf(context).width < 600) ...[
          number,
          const SizedBox(height: 24),
          detail,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              number,
              const SizedBox(width: 40),
              Expanded(child: detail),
            ],
          ),
        const SizedBox(height: 40),
        if (categories.isEmpty)
          const Text('No street crime was recorded near here in either month.')
        else ...[
          _Row(
            'By category',
            results.thisMonth,
            'Change',
            style: text.labelLarge,
          ),
          const Divider(),
          for (final row in categories)
            _Row(row.category, row.count, row.change),
        ],
      ],
    );
  }
}

Color _trendColor(ColorScheme scheme, Trend trend) => switch (trend) {
  Trend.down => scheme.primary,
  Trend.up => scheme.tertiary,
  Trend.flat => scheme.onSurfaceVariant,
};

class _MonthBar extends StatelessWidget {
  const _MonthBar(this.month, this.count, this.fraction, this.color);

  final String month;
  final int count;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Row(
      children: [
        SizedBox(width: 72, child: Text(month, style: style)),
        Expanded(child: _Bar(fraction, color)),
        SizedBox(
          width: 56,
          child: Text(
            formatCount(count),
            style: style,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.fraction, this.color);

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 10,
        alignment: Alignment.centerLeft,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: FractionallySizedBox(
          widthFactor: fraction,
          child: ColoredBox(color: color, child: const SizedBox.expand()),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.category, this.count, this.change, {this.style});

  final String category;
  final String count;
  final String change;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DefaultTextStyle.merge(
        style: style,
        child: Row(
          children: [
            Expanded(child: Text(category)),
            SizedBox(width: 72, child: Text(count, textAlign: TextAlign.end)),
            SizedBox(width: 72, child: Text(change, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.icon, this.text, {this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
        if (action case final action?) ...[const SizedBox(height: 16), action],
      ],
    );
  }
}
