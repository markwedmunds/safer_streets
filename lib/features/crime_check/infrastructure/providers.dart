import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/crime_repository.dart';
import 'api_crime_repository.dart';
import 'police_api.dart';
import 'postcodes_api.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  // No headers: data.police.uk rejects the CORS preflight they would trigger.
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
PostcodesApi postcodesApi(Ref ref) => PostcodesApi(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
PoliceApi policeApi(Ref ref) => PoliceApi(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
CrimeRepository crimeRepository(Ref ref) => ApiCrimeRepository(
  ref.watch(postcodesApiProvider),
  ref.watch(policeApiProvider),
);
