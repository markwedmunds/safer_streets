# Safer Streets

Flutter web app: type a UK postcode, see whether street crime nearby went up or down last month.

- Least code that meets the brief. If it isn't needed, leave it out and list it under "next steps" in the README.
- Flutter is pinned in `.fvmrc`; run everything through `fvm flutter`.
- Riverpod with codegen. Run `fvm dart run build_runner build` after changing providers, and commit the `.g.dart` files.
- Layers under `lib/features/crime_check/`: `domain/` (plain Dart, no Flutter or Dio), `infrastructure/`, `presentation/`.
- Vocabulary: `AreaReport` (`AreaFound`, `AreaNotCovered`, `AreaNotFound`) is returned; `AppFailure` (`NetworkFailure`, `RateLimited`, `AreaTooBusy`, `MonthNotPublished`, `BadData`) is thrown; `CrimeCheckState` is `Idle`, `Loading`, `Results`, `NotCovered`, `NotFound` or `Failed`.
- Errors: only `api_crime_repository.dart` catches, mapping to `AppFailure` in one function. User-facing messages come from one `switch` on the failure.
- Retry only on `areaReportProvider` (network failures and 429, at most 2). Retry is off for every other provider.
- data.police.uk: never send request headers (the CORS preflight is rejected). Take months from `crimes-street-dates`; never compute them.
- Decide Scotland, Isle of Man and Channel Islands are not covered from postcodes.io `country`, before calling the police API.
- Widgets contain no logic. Comments only where the why isn't obvious.
- Zero analyzer warnings, `dart format` clean, tests green before every commit.
- Commits are small, prefixed `Feature:`, `Fix:`, `Test:`, `Docs:` or `Chore:`.
