import 'package:flutter_test/flutter_test.dart';
import 'package:safer_streets/features/crime_check/domain/postcode.dart';

void main() {
  test('normalises case and spacing', () {
    expect(Postcode.tryParse('wa11uh')?.value, 'WA1 1UH');
    expect(Postcode.tryParse('  Wa1   1uH ')?.value, 'WA1 1UH');
    expect(Postcode.tryParse('sw1a1aa')?.value, 'SW1A 1AA');
    expect(Postcode.tryParse('M1 1AE')?.value, 'M1 1AE');
  });

  test('rejects partial postcodes and nonsense', () {
    for (final input in ['WA1 1', 'WA1', '', 'hello', '123 456']) {
      expect(Postcode.tryParse(input), isNull, reason: input);
    }
  });
}
