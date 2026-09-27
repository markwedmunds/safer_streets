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
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  // Out, then in: overlapping text is hard to read.
                  switchInCurve: const Interval(0.5, 1),
                  switchOutCurve: const Interval(0.5, 1),
                  // The default centres its children; this page reads from
                  // the left.
                  layoutBuilder: (current, previous) => Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: [...previous, ?current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state.runtimeType),
                    child: switch (state) {
                      Idle() => const SizedBox.shrink(),
                      Loading() => Row(
                        children: [
                          const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Busy areas can take up to 15 seconds.',
                              style: muted,
                            ),
                          ),
                        ],
                      ),
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
                ),
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
          child: SizedBox(
            width: double.infinity,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class _Examples extends StatelessWidget {
  const _Examples({required this.onSearch});

  final ValueChanged<String> onSearch;

  /// England, Wales, Northern Ireland, and Scotland to show not covered.
  static const _postcodes = ['WA1 1UH', 'CF10 1EP', 'BT1 5GS', 'EH1 1YZ'];

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
        for (final postcode in _postcodes)
          TextButton(
            onPressed: () => onSearch(postcode),
            child: Text(postcode),
          ),
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
              if (comparison != null) ...[
                TextSpan(
                  text: comparison.change,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _trendColor(theme.colorScheme, results.crime.trend),
                  ),
                ),
                TextSpan(text: comparison.rest),
              ],
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
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 40),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Text(results.highlights, style: text.bodyLarge),
          const SizedBox(height: 32),
          Text('Crime by category', style: text.titleLarge),
          const SizedBox(height: 16),
          Text(
            '${results.thisMonth}, and change on ${results.lastMonth}',
            style: muted,
          ),
          const SizedBox(height: 8),
          Divider(height: 2, thickness: 2, color: theme.colorScheme.onSurface),
          for (final row in categories) ...[
            _CategoryRow(row),
            const Divider(height: 1),
          ],
          const SizedBox(height: 16),
          Text(
            '≈ About the same means within 5%. Each month is published about '
            'two months later, and locations are moved to a nearby point to '
            'protect privacy.',
            style: muted,
          ),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(this.row);

  final CategoryRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(row.category)),
              Text(
                row.count,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _Bar(
                  row.bar,
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  row.change,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _trendColor(theme.colorScheme, row.trend),
                  ),
                ),
              ),
            ],
          ),
        ],
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
