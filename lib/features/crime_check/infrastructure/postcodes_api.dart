import 'package:dio/dio.dart';

import '../domain/failure.dart';
import '../domain/postcode.dart';

typedef Place = ({String country, String name, num? latitude, num? longitude});

class PostcodesApi {
  const PostcodesApi(this._dio);

  final Dio _dio;

  Future<Place?> lookup(Postcode postcode, CancelToken cancelToken) async {
    final response = await _dio.get<Object?>(
      'https://api.postcodes.io/postcodes/${postcode.value.replaceAll(' ', '')}',
      cancelToken: cancelToken,
      options: Options(
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );
    if (response.statusCode == 404) return null;
    if (response.data case {
      'result': {
        'country': final String country,
        'admin_district': final String? district,
        'latitude': final num? latitude,
        'longitude': final num? longitude,
      },
    }) {
      return (
        country: country,
        name: district ?? postcode.value,
        latitude: latitude,
        longitude: longitude,
      );
    }
    throw const BadData();
  }
}
