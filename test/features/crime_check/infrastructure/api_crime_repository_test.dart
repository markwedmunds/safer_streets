import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:safer_streets/features/crime_check/domain/area_report.dart';
import 'package:safer_streets/features/crime_check/domain/crime_repository.dart';
import 'package:safer_streets/features/crime_check/domain/failure.dart';
import 'package:safer_streets/features/crime_check/domain/postcode.dart';
import 'package:safer_streets/features/crime_check/infrastructure/providers.dart';

const _warrington = 'https://api.postcodes.io/postcodes/WA11UH';
const _edinburgh = 'https://api.postcodes.io/postcodes/EH11YZ';
const _months = 'https://data.police.uk/api/crimes-street-dates';
const _crimes = 'https://data.police.uk/api/crimes-street/all-crime';

Object? _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

void main() {
  late DioAdapter server;
  late CrimeRepository repository;
  late List<RequestOptions> requests;

  setUp(() {
    final container = ProviderContainer.test();
    final dio = container.read(dioProvider);
    server = DioAdapter(dio: dio);
    requests = [];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.next(options);
        },
      ),
    );
    repository = container.read(crimeRepositoryProvider);
  });

  void stubCrimes(String month, int status, [Object? body]) => server.onGet(
    _crimes,
    (s) => s.reply(status, body),
    queryParameters: {'lat': 53.389713, 'lng': -2.599634, 'date': month},
  );

  void stubWarrington() {
    server
      ..onGet(_warrington, (s) => s.reply(200, _fixture('postcode_wa1_1uh')))
      ..onGet(_months, (s) => s.reply(200, _fixture('crimes_street_dates')));
  }

  Future<AreaReport> report(String postcode) =>
      repository.reportFor(Postcode.tryParse(postcode)!);

  test('loads two months for WA1 1UH, sending no request headers', () async {
    stubWarrington();
    for (final month in ['2026-07', '2026-06']) {
      stubCrimes(month, 200, _fixture('crimes_wa1_1uh_$month'));
    }

    final crime = (await report('WA1 1UH') as AreaFound).crime;

    expect(crime.locationName, 'Warrington');
    expect(crime.thisMonth.month, DateTime(2026, 7));
    expect(crime.thisMonth.counts.total, 456);
    expect(crime.lastMonth.month, DateTime(2026, 6));
    expect(crime.lastMonth.counts.total, 503);
    expect(requests, hasLength(4));
    for (final request in requests) {
      expect(request.headers, isEmpty, reason: '${request.uri}');
    }
  });

  test('Scotland is not covered, with no police request', () async {
    server.onGet(_edinburgh, (s) => s.reply(200, _fixture('postcode_eh1_1yz')));

    expect(await report('EH1 1YZ'), isA<AreaNotCovered>());
    expect(requests.map((r) => r.uri.host), ['api.postcodes.io']);
  });

  group('maps failures', () {
    for (final (status, failure) in [
      (404, isA<MonthNotPublished>()),
      (429, isA<RateLimited>()),
      (503, isA<AreaTooBusy>()),
      (500, isA<NetworkFailure>()),
    ]) {
      test('$status from the crimes endpoint', () async {
        stubWarrington();
        for (final month in ['2026-07', '2026-06']) {
          stubCrimes(month, status);
        }

        await expectLater(report('WA1 1UH'), throwsA(failure));
      });
    }

    test('503 from postcodes.io is an outage, not a busy area', () async {
      server.onGet(_warrington, (s) => s.reply(503, null));

      await expectLater(report('WA1 1UH'), throwsA(isA<NetworkFailure>()));
    });

    test('connection error', () async {
      server.onGet(
        _warrington,
        (s) => s.throws(
          0,
          DioException.connectionError(
            requestOptions: RequestOptions(),
            reason: 'offline',
          ),
        ),
      );

      await expectLater(report('WA1 1UH'), throwsA(isA<NetworkFailure>()));
    });
  });
}
