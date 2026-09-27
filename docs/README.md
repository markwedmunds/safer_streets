# Notes

Two short references behind the [main README](../README.md): what testing the real APIs turned up, and how to force each state of the app in a browser.

## API notes

Found by calling both APIs directly before writing any code. The responses the tests replay are recorded in [`test/fixtures/`](../test/fixtures).

| What the API does | Why it matters | How the app handles it |
| --- | --- | --- |
| data.police.uk answers a CORS preflight with `403` | A header such as `Content-Type: application/json` makes every request fail in the browser with an opaque connection error that looks like an outage | Dio is configured with no headers at all; a repository test checks every request |
| Scotland returns `200 []` | Identical to an area with no crime | Decided from postcodes.io's `country` before calling the police API |
| Isle of Man and Channel Islands postcodes have no coordinates | There's nothing to send to the police API | Also decided from `country`: not covered |
| Data is published monthly, about two months late | Computing "last month" from today's date asks for a month that doesn't exist | The two months come from `crimes-street-dates`, newest first |
| An unpublished month is `404` with an empty HTML body, not `[]` | It isn't "no crime" | `MonthNotPublished`, with its own message |
| A `503` from the crimes endpoint means over 10,000 crimes | Retrying can't help | `AreaTooBusy`, never retried; a `503` from postcodes.io is an outage and is retried |
| `429` above 15 requests a second (bursts of 30) | `Retry-After` isn't exposed to the browser, so an accurate countdown is impossible | Retried with backoff and jitter, at most twice |
| A busy area (Soho) returns about 5,000 records, 2MB, in 6 to 12s | Close to the 15s receive timeout | Only `category` is read; the loading state says busy areas can take up to 15 seconds |
| New categories can appear | An unknown label would drop crimes | Anything unknown is counted under "Other crime" |

## Forcing each state in Chrome

Most states come from real postcodes. The rest can be forced with Chrome DevTools, without any code in the app for it.

| State | How to get it |
| --- | --- |
| Results | `WA1 1UH`, `CF10 1EP` (Wales), `BT1 5GS` (Northern Ireland) |
| Not covered | `EH1 1YZ` (Scotland), `IM1 1AE` (Isle of Man): no request to data.police.uk in the Network panel |
| Not found | `ZZ9 9ZZ` |
| Invalid input | `WA1 1`: a message under the field and no request |
| Slow loading | Network panel, throttling set to a slow preset, then `W1D 3QU` |
| Outage, retries, Try again | Network panel set to Offline, or block `data.police.uk` under Network request blocking. Search: the Network panel shows 3 attempts, then the error. Go back online and press Try again |
| Unreadable data | Search once, then in the Network panel right-click a `crimes-street/all-crime` request, choose Override content, and replace the body with `{"error": true}`. Reload the page (results are cached for 15 minutes) and search again: "The crime data came back in a form we couldn't read." |
| No crime | Override both months' `crimes-street/all-crime` requests with `[]`, reload and search: "No crimes reported in July or June" |
| Too busy, rate limited | DevTools can't change a status code, so the `503` and `429` paths are covered by the repository tests |

The same states were checked with Playwright against the release `--wasm` build, by intercepting the same requests.
