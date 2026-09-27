import 'area_report.dart';
import 'failure.dart';
import 'postcode.dart';

abstract interface class CrimeRepository {
  /// Street crime near [postcode] in the two latest published months.
  ///
  /// Throws an [AppFailure] if the report can't be loaded. Completing
  /// [cancelled] abandons the requests.
  Future<AreaReport> reportFor(Postcode postcode, {Future<void>? cancelled});
}
