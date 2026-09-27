/// Why a report couldn't be loaded. Thrown, never returned.
sealed class AppFailure implements Exception {
  const AppFailure();
}

/// Offline, timed out or a server error.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({this.retryable = true});

  /// False after a receive timeout: the server is still working on the
  /// query, so asking again only adds load.
  final bool retryable;
}

final class RateLimited extends AppFailure {
  const RateLimited();
}

/// data.police.uk refuses areas with over 10,000 crimes in a month.
final class AreaTooBusy extends AppFailure {
  const AreaTooBusy();
}

final class MonthNotPublished extends AppFailure {
  const MonthNotPublished();
}

final class BadData extends AppFailure {
  const BadData();
}
