// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crime_check_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One provider per postcode, so a new search disposes the old one and
/// cancels its requests.

@ProviderFor(areaReport)
final areaReportProvider = AreaReportFamily._();

/// One provider per postcode, so a new search disposes the old one and
/// cancels its requests.

final class AreaReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<AreaReport>,
          AreaReport,
          FutureOr<AreaReport>
        >
    with $FutureModifier<AreaReport>, $FutureProvider<AreaReport> {
  /// One provider per postcode, so a new search disposes the old one and
  /// cancels its requests.
  AreaReportProvider._({
    required AreaReportFamily super.from,
    required Postcode super.argument,
  }) : super(
         retry: _retry,
         name: r'areaReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$areaReportHash();

  @override
  String toString() {
    return r'areaReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AreaReport> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AreaReport> create(Ref ref) {
    final argument = this.argument as Postcode;
    return areaReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AreaReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$areaReportHash() => r'd206a96486365fff9f7769c42615c69216d04a63';

/// One provider per postcode, so a new search disposes the old one and
/// cancels its requests.

final class AreaReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AreaReport>, Postcode> {
  AreaReportFamily._()
    : super(
        retry: _retry,
        name: r'areaReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One provider per postcode, so a new search disposes the old one and
  /// cancels its requests.

  AreaReportProvider call(Postcode postcode) =>
      AreaReportProvider._(argument: postcode, from: this);

  @override
  String toString() => r'areaReportProvider';
}

@ProviderFor(CrimeCheckViewModel)
final crimeCheckViewModelProvider = CrimeCheckViewModelProvider._();

final class CrimeCheckViewModelProvider
    extends $NotifierProvider<CrimeCheckViewModel, CrimeCheckState> {
  CrimeCheckViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crimeCheckViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crimeCheckViewModelHash();

  @$internal
  @override
  CrimeCheckViewModel create() => CrimeCheckViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrimeCheckState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrimeCheckState>(value),
    );
  }
}

String _$crimeCheckViewModelHash() =>
    r'e98f6ff69ee046a5ff986313093ab93b40a59e23';

abstract class _$CrimeCheckViewModel extends $Notifier<CrimeCheckState> {
  CrimeCheckState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CrimeCheckState, CrimeCheckState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CrimeCheckState, CrimeCheckState>,
              CrimeCheckState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
