import 'dart:math';

import '../domain/area_report.dart';
import '../domain/failure.dart';
import '../domain/postcode.dart';

typedef CategoryRow = ({
  String category,
  String count,
  double bar,
  String change,
  Trend trend,
});

sealed class CrimeCheckState {
  const CrimeCheckState();
}

final class Idle extends CrimeCheckState {
  const Idle({this.invalidInput = false});

  final bool invalidInput;
}

final class Loading extends CrimeCheckState {
  const Loading();
}

final class Results extends CrimeCheckState {
  const Results(this.crime, this.postcode);

  final AreaCrime crime;
  final Postcode postcode;

  int get total => crime.thisMonth.counts.total;
  int get lastTotal => crime.lastMonth.counts.total;
  String get thisMonth => _monthName(crime.thisMonth.month);
  String get lastMonth => _monthName(crime.lastMonth.month);

  String get location =>
      '${postcode.value}, ${crime.locationName} · '
      '$thisMonth ${crime.thisMonth.month.year} compared with $lastMonth';

  String get heading => switch (crime.trend) {
    Trend.down => 'Fewer crimes than in $lastMonth',
    Trend.up => 'More crimes than in $lastMonth',
    Trend.flat => 'About the same as $lastMonth',
  };

  String get summary =>
      '${formatCount(total)} crimes were reported within about a mile in '
      '$thisMonth. '
      'That is ';

  /// Completes [summary]: "↓ 9% fewer" (emphasised), then the rest.
  ({String change, String rest}) get comparison {
    final percent = lastTotal == 0
        ? ''
        : '${((total - lastTotal).abs() * 100 / lastTotal).round()}% ';
    final rest = '$lastMonth, when there were ${formatCount(lastTotal)}.';
    return switch (crime.trend) {
      Trend.down => (change: '↓ ${percent}fewer', rest: ' than in $rest'),
      Trend.up => (change: '↑ ${percent}more', rest: ' than in $rest'),
      Trend.flat => (change: '≈ about the same', rest: ' as in $rest'),
    };
  }

  /// Bar lengths for this month and last, the larger one full width.
  (double, double) get bars {
    final most = max(total, lastTotal);
    return most == 0 ? (0, 0) : (total / most, lastTotal / most);
  }

  /// "Violence and sexual offences was the most common. Anti-social
  /// behaviour fell the most, down 13."
  String get highlights {
    final rows = crime.categories;
    if (rows.isEmpty) return '';
    final common = rows.first.category;
    final mover = rows.reduce(
      (a, b) => b.change.abs() > a.change.abs() ? b : a,
    );
    final moved = mover.change < 0
        ? 'fell the most, down ${-mover.change}'
        : 'rose the most, up ${mover.change}';
    if (total > 0 && mover.change != 0 && mover.category == common) {
      return '$common was the most common, and $moved.';
    }
    return [
      if (total > 0) '$common was the most common.',
      if (mover.change != 0) '${mover.category} $moved.',
    ].join(' ');
  }

  /// Largest first. [bar] is relative to the largest category.
  List<CategoryRow> get categories {
    final rows = crime.categories;
    final most = rows.isEmpty ? 0 : rows.first.count;
    return [
      for (final row in rows)
        (
          category: row.category,
          count: formatCount(row.count),
          bar: most == 0 ? 0 : row.count / most,
          change: switch (row.trend) {
            Trend.down => '↓ ${formatCount(-row.change)} fewer',
            Trend.up => '↑ ${formatCount(row.change)} more',
            Trend.flat => '≈ About the same',
          },
          trend: row.trend,
        ),
    ];
  }
}

final class NotCovered extends CrimeCheckState {
  const NotCovered();
}

final class NotFound extends CrimeCheckState {
  const NotFound();
}

final class Failed extends CrimeCheckState {
  const Failed(this.failure, this.postcode);

  final AppFailure failure;

  /// What Try again searches for.
  final Postcode postcode;

  String get message => switch (failure) {
    NetworkFailure(retryable: false) =>
      'The police data service is slow right now. Try again in a moment.',
    NetworkFailure() =>
      "Couldn't reach the crime data. Check your connection and try again.",
    RateLimited() => 'Too many searches at once. Wait a moment and try again.',
    AreaTooBusy() =>
      'There are too many crimes near here to count. Try a nearby postcode.',
    MonthNotPublished() =>
      "Last month's figures aren't fully published yet. Try again later.",
    BadData() => "The crime data came back in a form we couldn't read.",
  };
}

/// 5043 becomes "5,043".
String formatCount(int count) =>
    '$count'.replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');

String _monthName(DateTime month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month.month - 1];
