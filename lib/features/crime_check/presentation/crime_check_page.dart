import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Safer Streets', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Did street crime near you go up or down last month?',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _field,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Postcode',
                    hintText: 'e.g. WA1 1UH',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    errorText: switch (state) {
                      Idle(invalidInput: true) => 'Enter a full UK postcode',
                      _ => null,
                    },
                  ),
                  onSubmitted: _search,
                  // Stay in the field for the next search on desktop; on
                  // touch, closing the keyboard reveals the results.
                  onEditingComplete: switch (defaultTargetPlatform) {
                    TargetPlatform.android || TargetPlatform.iOS => null,
                    _ => () {},
                  },
                ),
                const SizedBox(height: 32),
                switch (state) {
                  Idle() => _Examples(onSearch: _search),
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
                const SizedBox(height: 32),
                Text(
                  'Street crime within a mile of the postcode, '
                  'from data.police.uk and postcodes.io.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
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
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Try'),
        for (final MapEntry(key: place, value: postcode) in _postcodes.entries)
          ActionChip(label: Text(place), onPressed: () => onSearch(postcode)),
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
    final crime = results.crime;
    final categories = results.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          crime.locationName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(results.heading, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            _Total(results.thisMonth, crime.thisMonth.counts.total),
            const SizedBox(width: 12),
            _Total(results.lastMonth, crime.lastMonth.counts.total),
          ],
        ),
        const SizedBox(height: 24),
        if (categories.isEmpty)
          const Text('No street crime was recorded near here in either month.')
        else ...[
          _Row(
            'By category',
            results.thisMonth,
            'Change',
            style: theme.textTheme.labelLarge,
          ),
          const Divider(),
          for (final row in categories)
            _Row(row.category, row.count, row.change),
        ],
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.month, this.count);

  final String month;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: theme.textTheme.displaySmall),
              Text('crimes in $month', style: theme.textTheme.bodyMedium),
            ],
          ),
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
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center),
        if (action case final action?) ...[const SizedBox(height: 16), action],
      ],
    );
  }
}
