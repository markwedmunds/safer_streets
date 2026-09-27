import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:safer_streets/features/crime_check/domain/area_report.dart';
import 'package:safer_streets/features/crime_check/domain/failure.dart';

void main() {
  group('CrimeCounts', () {
    test('counts a real response by category', () {
      final json = jsonDecode(
        File('test/fixtures/crimes_wa1_1uh_2026-07.json').readAsStringSync(),
      );

      final counts = CrimeCounts.fromJson(json);

      expect(counts.total, 456);
      expect(counts.byCategory['Violence and sexual offences'], 189);
      expect(counts.byCategory['Criminal damage and arson'], 23);
    });

    test('puts unknown categories under Other crime', () {
      final counts = CrimeCounts.fromJson([
        {'category': 'other-crime'},
        {'category': 'something-new'},
      ]);

      expect(counts.byCategory, {'Other crime': 2});
    });

    test('an unreadable payload throws BadData', () {
      for (final json in [
        null,
        'Internal error',
        {'category': 'drugs'},
        [
          42,
          {'type': 'drugs'},
        ],
      ]) {
        expect(
          () => CrimeCounts.fromJson(json),
          throwsA(isA<BadData>()),
          reason: '$json',
        );
      }
    });
  });

  test('a change under 5% of last month is flat', () {
    Trend trend(int thisMonth, int lastMonth) => AreaCrime(
      locationName: 'Warrington',
      thisMonth: (
        month: DateTime(2026, 7),
        counts: CrimeCounts({'Drugs': thisMonth}),
      ),
      lastMonth: (
        month: DateTime(2026, 6),
        counts: CrimeCounts({'Drugs': lastMonth}),
      ),
    ).trend;

    expect(trend(96, 100), Trend.flat);
    expect(trend(104, 100), Trend.flat);
    expect(trend(95, 100), Trend.down);
    expect(trend(105, 100), Trend.up);
    expect(trend(0, 0), Trend.flat);
    expect(trend(1, 0), Trend.up);
  });
}
