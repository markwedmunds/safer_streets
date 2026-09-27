import 'package:flutter/material.dart';

import '../domain/area_report.dart';
import '../domain/failure.dart';
import '../domain/postcode.dart';

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
  const Results(this.crime);

  final AreaCrime crime;

  String get thisMonth => _monthName(crime.thisMonth.month);
  String get lastMonth => _monthName(crime.lastMonth.month);

  String get heading => switch (crime.trend) {
    Trend.down => 'Fewer crimes than in $lastMonth',
    Trend.up => 'More crimes than in $lastMonth',
    Trend.flat => 'About the same as $lastMonth',
  };

  IconData get trendIcon => switch (crime.trend) {
    Trend.down => Icons.trending_down,
    Trend.up => Icons.trending_up,
    Trend.flat => Icons.trending_flat,
  };

  List<({String category, String count, String change})> get categories => [
    for (final row in crime.categories)
      (
        category: row.category,
        count: '${row.count}',
        change: row.change > 0 ? '+${row.change}' : '${row.change}',
      ),
  ];
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
