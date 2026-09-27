import 'package:flutter_test/flutter_test.dart';
import 'package:safer_streets/features/crime_check/domain/area_report.dart';
import 'package:safer_streets/features/crime_check/domain/postcode.dart';
import 'package:safer_streets/features/crime_check/presentation/crime_check_state.dart';

Results _results(Map<String, int> july, Map<String, int> june) => Results(
  AreaCrime(
    locationName: 'Warrington',
    thisMonth: (month: DateTime(2026, 7), counts: CrimeCounts(july)),
    lastMonth: (month: DateTime(2026, 6), counts: CrimeCounts(june)),
  ),
  Postcode.tryParse('WA1 1UH')!,
);

void main() {
  test('puts the change in words', () {
    expect(_results({'Drugs': 456}, {'Drugs': 503}).comparison, (
      change: '↓ 9% fewer',
      rest: ' than in June, when there were 503.',
    ));
    expect(
      _results({'Drugs': 1521}, {'Drugs': 1294}).comparison?.change,
      '↑ 18% more',
    );
    expect(
      _results({'Drugs': 98}, {'Drugs': 100}).comparison?.change,
      '≈ about the same',
    );
    expect(_results({'Drugs': 3}, {}).comparison?.change, '↑ more');

    final none = _results({}, {});
    expect(none.heading, 'No crimes reported in July or June');
    expect(none.comparison, isNull);
  });

  test('summarises the categories', () {
    final results = _results(
      {
        'Violence and sexual offences': 189,
        'Anti-social behaviour': 41,
        'Drugs': 22,
        'Burglary': 14,
      },
      {
        'Violence and sexual offences': 199,
        'Anti-social behaviour': 54,
        'Drugs': 22,
        'Burglary': 10,
      },
    );

    expect(
      results.highlights,
      'Violence and sexual offences was the most common. '
      'Anti-social behaviour fell the most, down 13.',
    );
    expect(results.categories.map((row) => row.change), [
      '↓ 10 fewer',
      '↓ 13 fewer',
      '≈ About the same',
      '↑ 4 more',
    ]);
    expect(
      _results({'Other theft': 1191}, {'Other theft': 1027}).highlights,
      'Other theft was the most common, and rose the most, up 164.',
    );
  });
}
