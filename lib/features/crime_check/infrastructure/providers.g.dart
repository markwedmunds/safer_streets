// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'465d459cafb14e9abd7140593cf6f7faa6c1eb93';

@ProviderFor(postcodesApi)
final postcodesApiProvider = PostcodesApiProvider._();

final class PostcodesApiProvider
    extends $FunctionalProvider<PostcodesApi, PostcodesApi, PostcodesApi>
    with $Provider<PostcodesApi> {
  PostcodesApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postcodesApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postcodesApiHash();

  @$internal
  @override
  $ProviderElement<PostcodesApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostcodesApi create(Ref ref) {
    return postcodesApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostcodesApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostcodesApi>(value),
    );
  }
}

String _$postcodesApiHash() => r'8a56f164075c9e7280388145e9aeb7006f7f3ad0';

@ProviderFor(policeApi)
final policeApiProvider = PoliceApiProvider._();

final class PoliceApiProvider
    extends $FunctionalProvider<PoliceApi, PoliceApi, PoliceApi>
    with $Provider<PoliceApi> {
  PoliceApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'policeApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$policeApiHash();

  @$internal
  @override
  $ProviderElement<PoliceApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PoliceApi create(Ref ref) {
    return policeApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoliceApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PoliceApi>(value),
    );
  }
}

String _$policeApiHash() => r'8930c59b25333fd432b7767291a214ed2e617079';

@ProviderFor(crimeRepository)
final crimeRepositoryProvider = CrimeRepositoryProvider._();

final class CrimeRepositoryProvider
    extends
        $FunctionalProvider<CrimeRepository, CrimeRepository, CrimeRepository>
    with $Provider<CrimeRepository> {
  CrimeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crimeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crimeRepositoryHash();

  @$internal
  @override
  $ProviderElement<CrimeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrimeRepository create(Ref ref) {
    return crimeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrimeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrimeRepository>(value),
    );
  }
}

String _$crimeRepositoryHash() => r'a77c93931523dc15fb79ad80ed7bc14a0018ea94';
