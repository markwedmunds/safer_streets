import 'failure.dart';

/// The answer for a postcode.
sealed class AreaReport {
  const AreaReport();
}

final class AreaFound extends AreaReport {
  const AreaFound(this.crime);

  final AreaCrime crime;
}

/// Scotland, the Isle of Man and the Channel Islands, which data.police.uk
/// doesn't publish.
final class AreaNotCovered extends AreaReport {
  const AreaNotCovered();
}

final class AreaNotFound extends AreaReport {
  const AreaNotFound();
}

enum Trend { up, down, flat }

typedef MonthCounts = ({DateTime month, CrimeCounts counts});

final class AreaCrime {
  const AreaCrime({
    required this.locationName,
    required this.thisMonth,
    required this.lastMonth,
  });

  final String locationName;
  final MonthCounts thisMonth;
  final MonthCounts lastMonth;

  Trend get trend {
    final change = thisMonth.counts.total - lastMonth.counts.total;
    if (change == 0 || change.abs() < lastMonth.counts.total * 0.05) {
      return Trend.flat;
    }
    return change > 0 ? Trend.up : Trend.down;
  }

  /// Every category seen in either month, largest this month first.
  List<({String category, int count, int change})> get categories {
    final now = thisMonth.counts.byCategory;
    final before = lastMonth.counts.byCategory;
    return [
      for (final category in {...now.keys, ...before.keys})
        (
          category: category,
          count: now[category] ?? 0,
          change: (now[category] ?? 0) - (before[category] ?? 0),
        ),
    ]..sort(
      (a, b) => a.count == b.count
          ? a.category.compareTo(b.category)
          : b.count.compareTo(a.count),
    );
  }
}

/// Crimes in one month, keyed by category label.
final class CrimeCounts {
  const CrimeCounts(this.byCategory);

  /// Counts a data.police.uk `crimes-street` response by `category`.
  ///
  /// Throws [BadData] unless it is a list with at least one readable record.
  /// Unreadable records among readable ones are skipped, and an empty list is
  /// a month with no crime.
  factory CrimeCounts.fromJson(Object? json) {
    if (json is! List) throw const BadData();
    final counts = <String, int>{};
    for (final record in json) {
      if (record case {'category': final String slug}) {
        final label = _labels[slug] ?? 'Other crime';
        counts.update(label, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    if (json.isNotEmpty && counts.isEmpty) throw const BadData();
    return CrimeCounts(counts);
  }

  final Map<String, int> byCategory;

  int get total => byCategory.values.fold(0, (sum, count) => sum + count);
}

const _labels = {
  'anti-social-behaviour': 'Anti-social behaviour',
  'bicycle-theft': 'Bicycle theft',
  'burglary': 'Burglary',
  'criminal-damage-arson': 'Criminal damage and arson',
  'drugs': 'Drugs',
  'other-theft': 'Other theft',
  'possession-of-weapons': 'Possession of weapons',
  'public-order': 'Public order',
  'robbery': 'Robbery',
  'shoplifting': 'Shoplifting',
  'theft-from-the-person': 'Theft from the person',
  'vehicle-crime': 'Vehicle crime',
  'violent-crime': 'Violence and sexual offences',
  'other-crime': 'Other crime',
};
