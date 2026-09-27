import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/area_report.dart';
import '../domain/failure.dart';
import '../domain/postcode.dart';
import '../infrastructure/providers.dart';
import 'crime_check_state.dart';

part 'crime_check_view_model.g.dart';

/// One provider per postcode, so a new search disposes the old one and
/// cancels its requests.
@Riverpod(retry: _retry)
Future<AreaReport> areaReport(Ref ref, Postcode postcode) async {
  final disposed = Completer<void>();
  ref.onDispose(disposed.complete);
  final report = await ref
      .watch(crimeRepositoryProvider)
      .reportFor(postcode, cancelled: disposed.future);

  // Crime figures change monthly, so keep successes for a while.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 15), link.close);
  ref.onDispose(timer.cancel);
  return report;
}

final _random = Random();

/// At most two retries, only for failures that may pass: about 0.2s then
/// 0.4s, randomised so clients don't retry in step.
Duration? _retry(int retryCount, Object error) {
  final retryable = switch (error) {
    NetworkFailure(:final retryable) => retryable,
    RateLimited() => true,
    _ => false,
  };
  if (!retryable || retryCount >= 2) return null;
  return Duration(milliseconds: 200 << retryCount) *
      (0.5 + _random.nextDouble());
}

@riverpod
class CrimeCheckViewModel extends _$CrimeCheckViewModel {
  Postcode? _postcode;
  var _invalidInput = false;

  @override
  CrimeCheckState build() {
    final postcode = _postcode;
    if (postcode == null) return Idle(invalidInput: _invalidInput);

    return switch (ref.watch(areaReportProvider(postcode))) {
      // Before errors: a retry, or Try again, is loading with the last error
      // still attached.
      AsyncValue(isLoading: true) || AsyncLoading() => const Loading(),
      AsyncData(value: AreaFound(:final crime)) => Results(crime),
      AsyncData(value: AreaNotCovered()) => const NotCovered(),
      AsyncData(value: AreaNotFound()) => const NotFound(),
      AsyncError(error: final AppFailure failure) => Failed(failure, postcode),
      // Anything else is a bug, so let it surface.
      AsyncError(:final error, :final stackTrace) => Error.throwWithStackTrace(
        error,
        stackTrace,
      ),
    };
  }

  /// Returns the postcode as understood, or null if [input] isn't one.
  Postcode? search(String input) {
    final postcode = Postcode.tryParse(input);
    // Searching the failed postcode again is Try again: ask afresh.
    if (postcode != null && postcode == _postcode && state is Failed) {
      ref.invalidate(areaReportProvider(postcode));
    }
    _postcode = postcode;
    _invalidInput = postcode == null;
    ref.invalidateSelf();
    return postcode;
  }
}
