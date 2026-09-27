import 'package:dio/dio.dart';

import '../domain/area_report.dart';
import '../domain/failure.dart';

class PoliceApi {
  const PoliceApi(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://data.police.uk/api';

  /// The latest published month and the one before, as `YYYY-MM`.
  Future<(String, String)> latestMonths(CancelToken cancelToken) async {
    final response = await _dio.get<Object?>(
      '$_baseUrl/crimes-street-dates',
      cancelToken: cancelToken,
    );
    final months = [
      if (response.data case final List entries)
        for (final entry in entries)
          if (entry case {'date': final String date}) date,
    ]..sort((a, b) => b.compareTo(a));
    if (months.length < 2) throw const BadData();
    return (months[0], months[1]);
  }

  Future<CrimeCounts> crimes({
    required num latitude,
    required num longitude,
    required String month,
    required CancelToken cancelToken,
  }) async {
    final response = await _dio.get<Object?>(
      '$_baseUrl/crimes-street/all-crime',
      queryParameters: {'lat': latitude, 'lng': longitude, 'date': month},
      cancelToken: cancelToken,
    );
    return CrimeCounts.fromJson(response.data);
  }
}
