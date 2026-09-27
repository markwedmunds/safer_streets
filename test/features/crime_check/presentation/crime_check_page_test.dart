import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safer_streets/app.dart';
import 'package:safer_streets/features/crime_check/domain/area_report.dart';
import 'package:safer_streets/features/crime_check/domain/crime_repository.dart';
import 'package:safer_streets/features/crime_check/domain/postcode.dart';
import 'package:safer_streets/features/crime_check/infrastructure/providers.dart';

class _FakeRepository implements CrimeRepository {
  @override
  Future<AreaReport> reportFor(
    Postcode postcode, {
    Future<void>? cancelled,
  }) async => AreaFound(
    AreaCrime(
      locationName: 'Warrington',
      thisMonth: (
        month: DateTime(2026, 7),
        counts: const CrimeCounts({'Violence and sexual offences': 189}),
      ),
      lastMonth: (
        month: DateTime(2026, 6),
        counts: const CrimeCounts({'Violence and sexual offences': 199}),
      ),
    ),
  );
}

void main() {
  testWidgets('typing a postcode and pressing Enter shows the heading', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          crimeRepositoryProvider.overrideWithValue(_FakeRepository()),
        ],
        child: const App(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'wa11uh');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('WA1 1UH'), findsOneWidget);
    expect(find.text('Fewer crimes than in June'), findsOneWidget);
    expect(
      find.text('WA1 1UH, Warrington · July 2026 compared with June'),
      findsOneWidget,
    );
    expect(find.text('-10'), findsOneWidget);
  });
}
