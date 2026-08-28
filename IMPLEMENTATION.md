# Ritual — Implementation Plan

*(package `daily_ritual`; the app shows as **Ritual** under its icon)*

> **Status:** all four phases complete (2026-08-28). V1 is feature-complete; see the checklist below.
> This is the durable reference for the project: design system, API registry, architecture and phase plan.
> Keep it updated as phases land.

## Context

The project began from a finished design canvas (`design/Daily Ritual.dc.html`, 797 lines, with its `support.js` / `image-slot.js` runtime). It was read end to end; it is a complete, self-consistent app design and remains the **UI source of truth**. Where it disagrees with the written spec, the disagreements are listed explicitly below rather than silently resolved.

Goal: a genuinely usable personal daily companion — something to do, learn, laugh at and be surprised by every calendar day — that keeps working offline.

### Decisions taken during planning

| Question | Decision |
|---|---|
| Platforms | **Android + iOS only.** Web and Linux dropped from §31. |
| Local storage | **Drift / SQLite**, single source of truth. Native sqlite3 both targets — no wasm, no `libsqlite3`. |
| Cloud | **Firestore mirror in Phase 4** (anonymous auth, last-write-wins). Explicitly *not* MongoDB. |
| CAT Quant | Provider chain with a **verified generator floor**. |
| Wordle | **§6 flow** — launch NYT, paste share text, parse. *Not* the in-app game the canvas draws. |
| Phasing | **4 phases**, each ending in a runnable app. |

**Why not MongoDB:** Atlas Data API, Custom HTTPS Endpoints, Device Sync and the Realm SDKs all reached end-of-life on **2025-09-30**. What remains is either `mongo_dart` connecting straight from the client — which ships the DB connection string inside the APK/IPA, violating §28 — or self-hosting a REST backend in front of Atlas. Firestore is the right cloud target here because it is the only free option with genuine offline persistence, which §17 requires.

**Toolchain:** Flutter 3.47.1 stable / Dart 3.13.1 (fvm, `/home/atharvas/fvm/default/bin`). Android builds run on this machine today. **iOS requires a Mac** — the Dart is platform-agnostic, only build and signing are blocked here.

---

## Phase status

| Phase | State | Notes |
|---|---|---|
| 0 — Scaffold | ✅ done | `flutter create` (android+ios), git init, design moved to `design/` |
| 1 — Foundation + first live content | ✅ done | Verified running on the Pixel 10 Pro emulator |
| 2 — Wordle, CAT Quant, completion & streaks | ✅ done | 203 tests; not yet exercised on device |
| 3 — Japan, Surprise, Settings, offline | ✅ done | 218 tests; not yet exercised on device |
| 4 — Notifications, Firestore, tests, release | ✅ done | 253 tests; release builds and signs |

### What Phase 1 shipped

Live and verified on device: Today dashboard with the Happy New Day greeting, OpenTDB trivia
(answering persists), PokéAPI Pokémon of the day, Cataas + Cat Facts, dog.ceo + Useless Facts,
JokeAPI, and a full local todo system. 74 unit tests pass; `flutter analyze` is clean.

Daily rollover was confirmed in the wild — the emulator crossed midnight during development and
the app correctly started a new day with fresh content while todos persisted.

### What Phase 4 shipped

Local notifications, opt-in Firestore backup, an end-to-end integration test, and a release build
that minifies, shrinks and signs.

### Phase 4 decisions

| Decision | Reason |
|---|---|
| **Sync is opt-in, off by default** | The plan called for silent anonymous auth. But onboarding tells the user "No account, nothing uploaded. Everything stays on this device" — uploading anyway would make that a lie. Sync lives behind a switch in Settings, so the promise holds for anyone who never turns it on. |
| **Turning sync off leaves the cloud copy alone** | Switching off a backup should not destroy it. |
| **Remote only wins when strictly newer** | A fresh install pulls history down; an active device never loses today's work to a stale cloud copy. |
| **One generic table mirror, not six** | Every synced table is the same shape — rows with a primary key and a timestamp — so they share an implementation. Drift's generated `toJson`/`fromJson` with an int-serialising `ValueSerializer` keeps what lands in Firestore as plain JSON. |
| **`app_settings` is synced too** | It carries the `seen:` completion markers, which is what makes a restored install show the right history rather than an empty timeline. |
| **The greeting is an *exact* alarm at 00:00** | Briefly changed to 08:00 on my own judgement, which was not mine to make — §16 says midnight. Inexact alarms drift by an hour or more under Doze, which would land a midnight greeting in the middle of the night, so this one is exact. Todo reminders stay inexact; 9am-ish is fine for those. |
| **The notification schedule is rebuilt every launch** | Android drops scheduled alarms on reboot *and* on app update. Assuming they survive means reminders silently stop working after an update. |
| **A dedicated monochrome status-bar icon** | Android renders notification icons from the alpha channel only; the colour launcher icon would appear as a white blob. |
| **The integration test seeds the cache instead of stubbing the network** | Seeded `daily_content` is exactly the path the app takes offline, so the test exercises the caching layer rather than bypassing it — and it cannot fail because a public API was slow. |
| **`-dontwarn com.google.android.play.core.**`** | Flutter's engine references Play Core's split-install API for deferred components, which this app does not use, so the library is absent and R8 stops on dangling references. Those code paths are never reached. |

### Release sizes

The universal APK is 67 MB because it carries three CPU architectures. Per-device, which is what a
user actually downloads once Play splits the bundle:

| ABI | Size |
|---|---|
| arm64-v8a | 26.5 MB |
| armeabi-v7a | 24.0 MB |

Upload `app-release.aab`, not an APK.

---

## V1 definition of done (§31)

| | |
|---|---|
| Android app launches | ✅ |
| Web / Linux launch | ➖ dropped by decision; Android + iOS only |
| Daily state changes after midnight | ✅ verified in the wild when the emulator crossed midnight |
| Happy New Day on a new day | ✅ |
| Wordle opens, share text imports, history and stats persist | ✅ |
| Daily Trivia from OpenTDB | ✅ |
| CAT question loads and its answer is validated | ✅ via the generator floor; every answer derived twice offline and confirmed against math.js |
| Daily animal/fun, Pokémon, Japan | ✅ |
| Surprise Me combines multiple APIs | ✅ |
| Todos work offline | ✅ |
| Daily completion and streaks | ✅ |
| Cached content works offline | ✅ |
| API failures don't crash the app | ✅ |
| Android notifications | ✅ |
| No secrets committed | ✅ |
| Tests cover critical business logic | ✅ 253 tests |

### Known gaps carried past V1

- **Widget test coverage is thin.** Only onboarding and the Wordle board have widget tests. Home,
  trivia, CAT, todos, history and surprise have none — a layout bug reached the emulator once
  because of this.
- **Google sign-in is not built.** Anonymous auth gives sync while the install lives, not recovery.
- **iOS is unverified.** Code is platform-agnostic but nothing has been built or run on a Mac.
- `assets/video/first-of-the-month.mp4` is still absent; the greeting branches on the 1st already.

---

### What Phase 3 shipped

Japan of the day, Surprise Me, the daily challenge, real Settings, and an offline banner.
All eleven home sections are now live and the completion ring reads its full **n / 7**.

### Phase 3 decisions

| Decision | Reason |
|---|---|
| **Japan curates *categories*, not places** | I had planned an authored list of ~200 place names. Wikipedia's `categorymembers` API removes the need: it enumerates what is in a category, so both the content *and* the choice come from the API. Only the category list is ours. |
| **Only tightly curated categories are used** | Broad ones return meta-articles and oddities — "Japanese cuisine" yields *Aspergillus oryzae* and *Blood sausage*, "Cities in Japan" yields *Prefectural road*. Gardens, World Heritage Sites, Festivals, Prefectures, Temples, Shrines, Folklore and National Treasures all return real subjects. |
| **A candidate must have a photo and a substantial extract** | The canvas puts a hero image on this card, so an entry without one cannot render as designed. That makes the image a functional requirement that doubles as a quality filter, rejecting stubs and disambiguation pages without any hand-maintained blocklist. |
| **The challenge is derived from the day's own content** | "Find out what Eevee evolves into" beats a canned prompt, and it makes the app feel joined up. Content-independent prompts remain as a floor so a failed fetch never leaves the day without a challenge. |
| **Surprise Me never touches the daily cache** | §12 requires it. It calls the services directly with a fresh random token rather than going through the repositories, so re-rolling cannot change what Today shows. All five sources fire together and the pack is built from whatever returns. |
| **Settings ships only controls that do something** | The canvas draws notification and appearance toggles. Notifications arrive in Phase 4, and a light palette would have to be invented since the canvas defines only dark — so rather than fake toggles, Settings has the name field and the dark-joke preference, and says plainly that notifications are coming. |
| **The offline banner sits above the nav, not at the top** | The tab bodies already own their status-bar inset; stacking a second `SafeArea` above them double-pads the page. |
| **Sentence splitting knows about abbreviations** | The "Did you know?" block splits the Wikipedia extract, and a naive split turns "Mt. Fuji" into two sentences, truncating the lead mid-phrase. Caught by a test. |

**Not yet done:** Phase 3 has not been exercised on the emulator.

---

### What Phase 2 shipped

**Wordle (§6).** `PLAY WORDLE` opens the real nytimes.com page in an in-app browser — a Chrome
Custom Tab on Android, `SFSafariViewController` on iOS. Nothing is scraped or reimplemented.
Returning from the puzzle auto-offers the paste sheet when the clipboard holds an unsaved share. The parser
handles thousands separators (`1,234`, `1 234`, `1.234`), the hard-mode asterisk, `X/6` failures,
light/dark squares and the colour-blind palette, and rejects anything else rather than guessing.
History shows streak, longest, average, games, the 1–6 distribution and a per-day timeline.

**CAT Quant (§8).** The chain runs OpenTDB (hard maths, filtered) → remote bank (disabled) →
generated. Nine parametric templates cover profit & loss, time & work, TSD, percentages, number
systems, P&C, probability, averages and mixtures.

**Streaks & completion (§14–15).** Wordle and CAT now count towards the ring, so it reads `n / 5`.
The streak flame is on the Today header.

### Phase 2 decisions

| Decision | Reason |
|---|---|
| **A pasted result is filed under the puzzle's own date**, not today's | Wordle #1 was 19 June 2021 and the numbering has run unbroken since (#1000 = 14 March 2024), so the number gives the date exactly. Pasting yesterday's share now lands on yesterday instead of corrupting today — and a future-dated puzzle is rejected outright. |
| **Importing counts as completing Wordle; solving is what streaks it** | Requiring a win to tick the box would punish the user for a hard word. But the *Wordle* streak follows NYT semantics and counts solved puzzles only. |
| **A streak survives a today that hasn't happened yet** | Measured to yesterday when today is empty. Otherwise every streak would appear to collapse at 00:01 and only recover once you played, which is punishing the user for the clock (§15). |
| **The failure average is left undefined, not imputed** | `X/6` has no score. Counting it as 6 or 7 would both be inventions, so failures are excluded from the average and shown in games/win rate instead. |
| **Every generated answer is derived twice offline before math.js is asked** | The online check is a third opinion, not the only one. A question whose two offline derivations disagree is discarded before any network call; if math.js actively disagrees it is discarded too. Only an unreachable math.js is tolerated, and the badge then reads "Verified offline". |
| **The canvas's "26% solved this correctly" became your own accuracy** | A global figure needs a backend and a userbase. Inventing one would be a lie, so the card shows the local hit rate from `cat_quant_results`. |
| **The OpenTDB maths tier is kept even though it nearly always rejects** | §8 asks for a public-API tier first. The filter demands a numeric answer and a question containing digits, which OpenTDB's "Science: Mathematics" trivia almost never satisfies — so in practice the generator answers. Keeping the tier costs one request and honours the spec. |
| **The in-app Wordle board is read-only** | The canvas drew a playable board with a keyboard; §6 forbids it. The board renders the pasted grid's pattern and no letters, because the share text carries none. |
| **`inAppBrowserView`, not `externalApplication` or `inAppWebView`** | Custom Tabs / `SFSafariViewController` keep Daily Ritual on the back stack, so play → Share → return → paste is one gesture instead of an app switch. They also share cookies with the default browser, so an existing NYT login and streak carry over — which `inAppWebView` would not, since it gets an isolated cookie jar and would silently sign the user out. |
| **Returning from Wordle auto-opens the paste sheet** | Only when the user actually just came back from the puzzle *and* the clipboard holds a share not already saved. Opening a sheet unprompted needs that much certainty; anything less stays silent. |

### Verified in Phase 2

`flutter analyze` clean; **203 tests pass**. Notably the templates are re-derived independently
*inside the test file* — profit, harmonic mean, trailing zeros, combinations, probability, mixture
ratio and the average substitution are each recomputed from the question text, so a mistake in a
template cannot hide behind its own arithmetic. All nine math.js expression forms were confirmed
against the live endpoint during development.

**Not yet done:** Phase 2 has not been exercised on the emulator.

---

### Decisions taken during Phase 1

| Decision | Reason |
|---|---|
| **Riverpod 3.4.2**, not 2.6.1 | `pub add` pinned 2.x, but 3.x resolves cleanly. Starting a greenfield project a major version behind means paying for the migration later. Note `AsyncValue.valueOrNull` is now `.value`, and `Ref`/`WidgetRef` stay distinct. |
| **Hand-written models**, no Freezed | Drift already requires `build_runner`. The models are small and mostly cached JSON, so a second generator would add failure surface without buying much. |
| **Plain Riverpod providers**, no `riverpod_annotation` | Same reasoning — fewer generated files to keep in sync. |
| **Outfit bundled as a variable font asset**, not `google_fonts` | Runtime font fetching would leave the first offline launch in a fallback face, contradicting §17. One 110 KB file covers the whole 100–900 axis. Weights are applied via `FontVariation`, since `fontWeight` alone leaves a variable font on its default instance. |
| **`sqlite3_flutter_libs` dropped** | Publisher marked it end-of-life ("update to version 3.x of package:sqlite3"). `drift_flutter` pulls what it needs. |
| `ApiResult` is **Success / Failure only** | Offline is an `ApiErrorKind` on the failure rather than a third case, so call sites branch twice while the UI can still tell "you're offline" from "the server broke". |
| **Explore built in Phase 1**, not Phase 3 | Pokémon and the animal content were already live; a placeholder tab would have been worse than the real thing. Phase 3 adds Japan and Surprise Me to it. |
| **Cat and dog both always on Explore** | The §9 rotation still drives the daily slot and completion, but asking for a dog and getting only a cat is a let-down. Each is cached under its own `fun-<kind>` key. |
| **`DailyCompletion` scores only available activities** | Wordle, CAT, Challenge and Surprise are marked unavailable until their phases land, so the ring reads `n / 3` today rather than counting unbuilt features as skipped. |
| **INTERNET permission declared explicitly** | Flutter only injects it into debug/profile builds; release would have had no network. |

### Known gaps carried into later phases

- The dog card's text comes from Useless Facts, because the dog-facts API (`dogapi.dog`) is dead.
  It is labelled "Did you know?" rather than implying it is about dogs.
- Settings is still an honest placeholder; its toggles arrive with the phases that give them
  something to control.
- `assets/video/first-of-the-month.mp4` is not present yet. The greeting already branches on the
  1st of the month and shows a text banner; the video drops into that branch when the file arrives
  (needs `flutter pub add video_player`).

---

## 1. Design system — extracted from the canvas

### Tokens (use verbatim)

```
bg #14131a      surface #1e1d26        surface-raised #292733
border #2d2b37  border-strong #3a3846
text #f5f3f7    text-secondary #ada9b8 text-tertiary #7c7889
accent #ff5ca8  accent-hover #ff7fbb   accent-soft #3d1c2c
accent-soft-text #ffb4d3               on-accent #26101b
success #2fd1a0 success-on #06231a     error #ff6b6b

feature accents: cat #7c8bff · trivia #ffc24d · pokemon #bd8dff
                 japan #ff7a68 · fun #2fd1a0

font: Outfit 400/500/600/700/800  (google_fonts)
```

### Type scale

| Role | Spec |
|---|---|
| Greeting | 30px w800, ls −0.015em, lh 1.08 |
| Tab title | 22px w800 |
| Screen title | 15px w800, ls 0.02em |
| Question stem | 17–19px w600/w800, lh 1.4–1.5 |
| Big stat | 26–28px w800, **tabular-nums** |
| Body | 13–14px, lh 1.4–1.65, text-secondary |
| Eyebrow / label | 10–11px w800, ls 0.08–0.14em, uppercase |

### Component rules

- **Card** — surface bg, padding 16–18, radius 16, `shadow 0 1px 2px rgba(0,0,0,.4)`, column gap 10–12; stack gap 14.
- **Accent card** (Surprise) — accent bg, radius 20, on-accent text, pill CTA with 1.5px on-accent border, radius 20.
- **Chip / badge** — 1.5px border in the feature colour, radius 6, 10–11px w700 uppercase.
- **Primary button** — accent bg, on-accent text, radius 10, padding 12–13 × 14–16, 13px w800 uppercase ls 0.03–0.05em. Disabled → surface-raised bg, text-tertiary, not-allowed.
- **Option row** — padding 13×14, radius 10, surface bg. Selected → 1.5px accent border. After submit: correct → success bg + success-on text + check icon; chosen-wrong → error border + error text + ✕; others → text-tertiary. CAT rows carry an A/B/C/D letter box (22×22, radius 6); trivia rows do not.
- **Checkbox** — 18×18, radius 5, 1.5px border-strong; done → accent fill with a bg-coloured check, label goes text-tertiary + strikethrough.
- **Dividers** — 2px border-strong for structural breaks, 1px border for in-card rules.
- **Bottom nav** — bg, 2px top border-strong, 5 items, 20px icon + 10px w700 label, active accent, plus a 2px accent indicator bar inset 20% at the top of the active item.
- **Detail screen** — full-bleed overlay, header 18×20 with back chevron + title, 2px bottom border-strong, scrolling body at padding 20.
- **Segmented control** — 1.5px border-strong, radius 10, active segment accent bg + on-accent.
- **Animations** — `riseIn` (opacity + 10px rise) 0.35–0.5s ease on tab/screen entry; `popIn` (opacity + scale 0.94) 0.3–0.35s on result reveals. Honour reduced-motion.

### Layout

Mobile frame 390×844. The canvas's "desktop" 2-column grid maps to a **tablet/landscape breakpoint at ≥900dp**: Today splits into a left column (greeting, progress, Wordle, CAT, Trivia, Explore teaser, Challenge, Todos, Surprise) and a right column (Japan hero, Todos + Challenge side by side, wide Surprise banner).

---

## 2. Screen inventory (from the canvas)

**Tabs:** Today · Explore · Todos · History · Settings
**Detail screens:** Wordle · CAT Quant · Daily Trivia · Pokémon Of The Day · Japan Of The Day · Surprise Me

- **Today** — weekday/date + bell, "Good morning, Atharva." / "Your daily ritual is ready.", `4 / 7` completed + 7 progress cells + flame streak, then cards: Wordle (preview row, PLAY WORDLE, streak/average), CAT Quant (difficulty · topic chip, stem, SOLVE →), Daily Trivia (category · difficulty chip, stem, ANSWER →), "More to explore today" teaser, Challenge row with a Done? toggle, Todos (3 items + SEE ALL), Surprise Me accent card.
- **Explore** — Surprise Me, Japan (image + title), Pokémon (thumb + name), Animal Fact (thumb + text).
- **Todos** — sections **Today / Upcoming / Overdue / Completed**, rows with checkbox + strikethrough, inline "Add a todo…" field + accent ✚ button.
- **History** — segmented Wordle | Timeline. Wordle: Streak / Longest / Average / Games, then a 1–6 distribution with the modal row in accent. Timeline: per-day rows with ✓/✕ per activity.
- **Settings** — Notifications (midnight alert, Wordle reminder, todo reminders), Appearance (Light/Dark/System), Daily Content (fun category, joke difficulty), About (API sources + version).
- **Surprise** — six stacked slots: Japan, Today's Animal, Pokémon, Did You Know?, A Joke, then an accent Your Challenge card, and ANOTHER SURPRISE.

The canvas confirms **daily completion is 7 items**: Wordle, CAT, Trivia, Fun, Pokémon, Challenge, Surprise (matches §14).

---

## 3. Where design and spec disagree — resolutions

| # | Conflict | Resolution |
|---|---|---|
| 1 | Canvas draws a **playable Wordle** (6×5 board, QWERTY keyboard, mid-game preview row, "NYT-style word list" in About). §6 forbids this. | **Follow §6.** PLAY WORDLE opens NYT externally; the board becomes a read-only render of the pasted grid; the keyboard is dropped; the home preview row shows the last imported result or an empty prompt. |
| 2 | CAT screen shows **"26% solved this correctly"** — impossible without a backend. | Replace with **your own accuracy** computed from `cat_quant_results`. No invented global stat. |
| 3 | Trivia result shows an **explanation paragraph**. OpenTDB provides none. | Render an explanation **only when the source supplies one**; otherwise show the correct answer alone. Never fabricate — same rule as §8. |
| 4 | Japan screen wants **tag chips** + a **"Did You Know?"** block. Wikipedia summary gives extract, description, thumbnail. | Chips from the Wikipedia `description` plus curated tags on the seed entry; Did-You-Know from a further extract sentence, **hidden when unavailable**. |
| 5 | Every `image-slot` carries `filter:grayscale(1) contrast(1.08)`. | Treated as **canvas placeholder styling** — real images render in colour. Pokémon artwork and cat photos lose their point in greyscale. |
| 6 | Canvas Todos have four sections; §13 lists three. | Follow the canvas: Today / Upcoming / Overdue / Completed. |
| 7 | Settings About credits a "custom CAT question bank". | Replaced by the honest source list from the registry below. |

---

## 4. API registry — every endpoint probed live during planning

All URLs live in **one** file, `lib/core/network/api_sources.dart` (§24). No URL appears anywhere else.

| Source | Endpoint | Status |
|---|---|---|
| OpenTDB | `opentdb.com/api.php?amount=1&category=&difficulty=&type=multiple` | ✅ 200 |
| The Trivia API (backup) | `the-trivia-api.com/v2/questions?limit=1` | ✅ 200 |
| PokéAPI | `pokeapi.co/api/v2/pokemon/{id}` + `/pokemon-species/{id}` | ✅ 200 |
| Cataas | `cataas.com/cat?json=true` | ✅ 200 |
| Cat Facts | `catfact.ninja/fact` | ✅ 200 |
| Dog images | `dog.ceo/api/breeds/image/random` | ✅ 200 |
| JokeAPI | `v2.jokeapi.dev/joke/Any?type=single` | ✅ 200 |
| Useless Facts | `uselessfacts.jsph.pl/api/v2/facts/random` | ✅ 200 |
| Wikipedia REST (Japan) | `en.wikipedia.org/api/rest_v1/page/summary/{title}` | ✅ 200 |
| math.js (CAT verification) | `api.mathjs.org/v4/?expr=` | ✅ 200 |

**Confirmed dead — do not use:** `aptitude-api.vercel.app` (404, deployment gone), `dogapi.dog` (connection failure), `numbersapi.com` (404), `api.jikan.moe` (504). Crucially, **no key-free CAT/aptitude question API exists** — that finding drives the CAT design in Phase 2.

---

## 5. Architecture

```
UI (widget)  →  Riverpod notifier  →  Repository  →  Service  →  Dio
                                          ↓
                                    Drift (cache + state)
```

Widgets never touch Dio (§18). Every repository is **cache-first**: read today's row from `daily_content`, fetch only on miss, write back on success.

```
lib/
├── app/            app.dart · router.dart · theme.dart
├── core/
│   ├── network/    api_client.dart · api_sources.dart · api_result.dart · api_exception.dart
│   ├── database/   database.dart · tables/
│   ├── dates/      daily_date_service.dart
│   ├── notifications/ notification_service.dart
│   └── utils/      daily_seed.dart
├── features/       home · wordle · trivia · cat_quant · animals · pokemon
│                   japan · surprise · challenges · todos   (each: data/domain/presentation)
└── shared/         widgets/ (RitualCard, Eyebrow, FeatureChip, OptionRow, PrimaryButton,
                    StatBlock, SectionDivider, ErrorCard, OfflineBadge) · models/
```

**Drift tables** (§21): `daily_states`, `wordle_results`, `trivia_results`, `cat_quant_results`, `daily_content`, `challenges`, `todos`, `surprises`, `app_settings`. `daily_content` is the generic cache — `(date, contentType, source, sourceId, payload JSON, createdAt)` — and is what makes §17 work.

**Daily rollover** — local calendar date as `yyyy-MM-dd`, checked on cold start **and** on `AppLifecycleState.resumed`, so closing at 23:50 and opening at 08:00 correctly starts a new day.

**Deterministic seeding** — FNV-1a over `"$date:$contentType"`, so each feature gets an independent but reproducible stream (§22). A single shared seed would correlate today's Pokémon with today's joke category.

---

## 6. Phases

### Phase 1 — Foundation + first live content

Ends with an installable Android app whose home screen shows today's real trivia, Pokémon and fun content, survives restarts, and rolls over correctly at midnight.

1. `flutter create --org com.atharva --platforms=android,ios --project-name daily_ritual .`; `git init`; `.gitignore` covering `*.jks`, `key.properties`, `google-services.json`, `GoogleService-Info.plist`, `.env` (§28). No commits unless asked.
2. Deps: `flutter_riverpod` + `riverpod_annotation`, `dio`, `freezed` + `json_serializable`, `go_router`, `drift` + `drift_flutter` + `sqlite3_flutter_libs`, `google_fonts`, `url_launcher`, `share_plus`, `cached_network_image`, `connectivity_plus`.
3. `theme.dart` — tokens above as `ThemeData` plus a `ThemeExtension` carrying the five feature accents. `router.dart` — GoRouter shell with 5 tabs + 6 detail routes.
4. `core/network/` — Dio with 10s connect / 15s receive timeouts, backoff retry on 5xx and timeouts (never on 4xx); `sealed class ApiResult<T>` → `Success` / `Failure` / `Offline`.
5. `core/database/` + `core/dates/` + `core/utils/daily_seed.dart` as described above.
6. `shared/widgets/` — build the component set from §1 first, so every later feature composes instead of restyling.
7. Live features: **Trivia** (OpenTDB, session token persisted in `app_settings` to avoid repeats), **Pokémon** (seed → species id; artwork, types, flavour text, 4 stat bars), **Daily Fun** (seed → category per the §9 rotation → Cataas / Cat Facts / dog.ceo / JokeAPI / Useless Facts).
8. **Todos** — full local CRUD, priority, due date, category, four canvas sections. No network, so this card can never fail.
9. **Home** — each card an independent `AsyncValue`; one failed API renders one error card with RETRY and leaves the rest of the page intact (§23).
10. **Happy New Day** greeting, shown once per new date (§5).

*Tests:* rollover, seed determinism, trivia/pokemon parsing, todo state transitions.

### Phase 2 — Wordle, CAT Quant, completion & streaks

Ends with the History tab populated by real statistics and a working completion ring.

**Wordle (§6).** PLAY WORDLE launches the NYT URL from the registry via `url_launcher` (Android Custom Tab / iOS `SFSafariViewController`). No scraping. Return, paste, parse: handles `Wordle 1,234 4/6*` — thousands separators, hard-mode asterisk, `X/6` failures — plus the emoji grid. The answer is never stored (the share text doesn't contain it). Stats: current/longest streak, average, best, total, the 1–6 distribution, recent history.

**CAT Quant (§8).** No key-free aptitude API exists, so the spec's chain gets a floor that always succeeds:

```
CatQuestionProvider
 ├─ OpenTdbMathProvider   (category 19, hard — filtered, usually rejects as too easy)
 ├─ RemoteBankProvider    (HTTPS JSON, URL in registry, swappable, optional)
 └─ GeneratedProvider     (parametric templates, date-seeded)  ← always available
```

`GeneratedProvider` builds genuine CAT-level items — TSD, time & work, profit & loss, ratio/mixtures, averages, number systems, P&C, probability — with parameters drawn from the daily seed, so today's question is stable across restarts. **Nothing is displayed unverified** (§8): the generator emits an answer plus an independent `verifyExpr` evaluated against `api.mathjs.org`; online, a mismatch discards the question and advances the seed; offline, the answer must agree across two independent derivation paths in code or it isn't shown. The screen carries a source badge and always reveals the worked solution after submission (the canvas's "Quick Solution" block). If every tier fails, the card shows the spec's `TRY AGAIN` empty state rather than a fabricated question.

**Completion & streaks (§14–15).** Informational, never punitive. Per-feature streaks are exact (Wordle streak = consecutive days with a saved result); the overall daily streak increments on any day with **at least one** completed activity, so skipping optional content never breaks it. Drives the `4 / 7` counter, the 7 progress cells and the History timeline.

*Tests:* the Wordle parser across every share-text variant, streak maths over gaps and edges, CAT verification rejecting a deliberately wrong answer.

### Phase 3 — Japan, Surprise, Explore & Settings, offline polish

Ends with all sections live and the app fully usable on a plane.

- **Japan** — a `JapanSource` interface so the source can change without touching UI (§11). First implementation: seeded pick from a curated list of ~200 place/culture/word *titles*, with all displayed content fetched from the Wikipedia REST summary API (text, image, licence). No scraping.
- **Surprise** — `SurpriseGenerator` composing the six independent sources into the canvas's six slots. ANOTHER SURPRISE re-rolls without mutating any official daily content; results persist to `surprises`.
- **Explore & Settings** tabs exactly as drawn, including the Appearance selector and content toggles.
- **Offline (§17)** — `connectivity_plus` drives the offline badge; cached content stays readable; uncached content shows RETRY and never crashes.
- **Polish** — `riseIn` / `popIn` entry animations, skeleton loaders, semantic labels, contrast and reduced-motion.

*Tests:* widget tests for home, trivia, CAT, todos, Wordle history, surprise.

### Phase 4 — Notifications, cloud sync, test pass, release

- **Notifications (§16)** behind a `NotificationService`: midnight Happy New Day, optional morning Wordle nudge, per-todo reminders. Android 13+ `POST_NOTIFICATIONS` and exact-alarm handling; iOS permission prompt. Individually toggleable from Settings; nothing on by default beyond the daily greeting.
- **Firestore mirror** — Drift stays the source of truth. `SyncService` mirrors `wordle_results`, `todos`, `daily_states` and streak counters under an anonymous-auth uid, reconciling by `updatedAt` (last-write-wins). Sync failure is always silent and non-blocking. Config files stay gitignored.
- **Integration test (§29)** — launch → create daily state → load content → answer trivia → complete todo → import Wordle result → verify history.
- **Release** — icons and splash from the canvas palette, Android signing template (keystore never committed), iOS bundle id and capabilities ready for a Mac build.

---

## 7. Verification

- **Per phase:** `flutter analyze` clean, `flutter test` green, then `flutter run` on an Android device and exercise that phase by hand.
- **Rollover:** move the device clock past midnight; confirm a new `daily_states` row, the Happy New Day greeting and fresh content. This is the one behaviour unit tests can't fully prove.
- **Offline:** airplane mode — every cached card still renders, todos remain fully functional.
- **Failure isolation:** point `ApiSources.openTrivia` at an unreachable host; only the trivia card may degrade.
- **Design fidelity:** compare each built screen against the canvas rendered in a browser.
- **Secrets:** `git status` must never show `google-services.json`, `GoogleService-Info.plist` or a keystore.

## 8. Open items (not blocking)

- iOS build and signing need a Mac — Phase 4's iOS steps will be code-complete but unverifiable here.
- `RemoteBankProvider` stays disabled until you decide whether to host a question JSON; the generator floor covers CAT Quant without it.
- Calling the section "Wordle" in-app is an NYT trademark; fine for personal use, worth renaming before any store listing.
