import 'package:dio/dio.dart';

import '../domain/area_report.dart';
import '../domain/crime_repository.dart';
import '../domain/failure.dart';
import '../domain/postcode.dart';
import 'police_api.dart';
import 'postcodes_api.dart';

class ApiCrimeRepository implements CrimeRepository {
  const ApiCrimeRepository(this._postcodes, this._police);

  final PostcodesApi _postcodes;
  final PoliceApi _police;

  /// data.police.uk has no data for anywhere else. Scotland returns `[]`,
  /// which would read as no crime, so this is decided before asking.
  static const _covered = {'England', 'Wales', 'Northern Ireland'};

  @override
  Future<AreaReport> reportFor(
    Postcode postcode, {
    Future<void>? cancelled,
  }) async {
    final cancelToken = CancelToken();
    cancelled?.whenComplete(cancelToken.cancel);
    try {
      final place = await _postcodes.lookup(postcode, cancelToken);
      if (place == null) return const AreaNotFound();
      if (!_covered.contains(place.country)) return const AreaNotCovered();

      final latitude = place.latitude;
      final longitude = place.longitude;
      if (latitude == null || longitude == null) throw const BadData();

      final (latest, previous) = await _police.latestMonths(cancelToken);
      Future<MonthCounts> countsFor(String month) async => (
        month: DateTime.parse('$month-01'),
        counts: await _police.crimes(
          latitude: latitude,
          longitude: longitude,
          month: month,
          cancelToken: cancelToken,
        ),
      );

      final [thisMonth, lastMonth] = await Future.wait([
        countsFor(latest),
        countsFor(previous),
      ]);

      return AreaFound(
        AreaCrime(
          locationName: place.name,
          thisMonth: thisMonth,
          lastMonth: lastMonth,
        ),
      );
    } on Exception catch (error) {
      throw _failureFrom(error);
    }
  }
}

AppFailure _failureFrom(Exception error) => switch (error) {
  AppFailure() => error,
  DioException(type: DioExceptionType.receiveTimeout) => const NetworkFailure(
    retryable: false,
  ),
  DioException(response: Response(statusCode: 429)) => const RateLimited(),
  // The crimes endpoint's way of saying "over 10,000 crimes". Anywhere else
  // a 503 is an outage.
  DioException(response: Response(statusCode: 503), :final requestOptions)
      when requestOptions.path.contains('/crimes-street/') =>
    const AreaTooBusy(),
  DioException(response: Response(statusCode: 404)) =>
    const MonthNotPublished(),
  DioException(response: Response(statusCode: final int status))
      when status >= 500 =>
    const NetworkFailure(),
  // Any other status, or a body that isn't valid JSON.
  DioException(response: Response()) ||
  DioException(error: FormatException()) => const BadData(),
  DioException() => const NetworkFailure(),
  _ => const BadData(),
};
