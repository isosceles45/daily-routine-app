# Ritual

A personal daily companion for Android and iOS. Every calendar day it puts
together something to do, something to learn, something funny and something
unexpected — and it keeps working with no signal.

Built in Flutter, offline-first, no account, no backend.

> The Dart package is `daily_ritual` and the application id is
> `com.atharva.daily_ritual` — those are identifiers and stay put. "Ritual" is
> what appears under the icon.

## What it does

| Section | Source |
|---|---|
| **Wordle** | Opens the real NYT page in an in-app browser, then imports your shared result. Streaks, average, guess distribution. |
| **CAT Quant** | A CAT-level quantitative question daily, with a worked solution. |
| **Daily Trivia** | [Open Trivia Database](https://opentdb.com) |
| **Pokémon of the day** | [PokéAPI](https://pokeapi.co) |
| **Place of the day** | [Wikipedia](https://en.wikipedia.org) — World Heritage sites, national parks and ancient sites across 16 countries |
| **Animal of the day** | [Cataas](https://cataas.com), [dog.ceo](https://dog.ceo), [RandomFox](https://randomfox.ca), [random-d.uk](https://random-d.uk), [bunnies.io](https://bunnies.io) |
| **Jokes & facts** | [JokeAPI](https://jokeapi.dev), [Useless Facts](https://uselessfacts.jsph.pl), [Cat Facts](https://catfact.ninja) |
| **Gym** | Your own weekly split, with exercises from [wger](https://wger.de)'s open database |
| **Play** | Quant Rush, Sudoku and 2048 — generated on device, no network at all |
| **Todos & countdowns** | Local only — no network, so they can never fail |

Every source is a keyless public API. **There are no secrets in this repo and
none are needed to build it.**

## The daily part ends. The app doesn't.

Everything above the fold is finished once you have done it, which made the app
a thing you opened at night, cleared, and closed. **Play** is the answer to
that: three games that are generated on the device, have no daily limit, and
work with no signal.

Sudoku generates a fresh grid and **removes clues only while exactly one
solution survives** — a puzzle with two solutions cannot be reasoned to an
answer, only guessed at. Quant Rush derives every answer twice by independent
routes before showing it, the same rule the CAT card follows.

## Two things worth knowing

**The day rolls over on its own.** A "day" is the device's local calendar date,
checked on cold start *and* whenever the app returns to the foreground. Close it
at 23:50, open it at 08:00, and it correctly knows a new day started — no
midnight network call, no background job.

**Content is deterministic per date.** Today's Pokémon, joke category and CAT
question are seeded from the date, so refreshing never reshuffles them. Each
feature hashes `"$date:$contentType"` rather than the bare date, so the streams
stay independent — otherwise every section would move in lockstep.

## CAT Quant answers are verified, never asserted

No key-free API serves CAT-level aptitude questions — the ones that used to are
dead, and OpenTDB's "Science: Mathematics" is trivia, not quantitative aptitude.
So the app runs a provider chain ending in a parametric generator, and **nothing
reaches the screen unverified**:

1. Each question is derived **twice offline** by independent routes. Disagree,
   and it is discarded before any network call.
2. When online it is confirmed a **third time** against
   [math.js](https://api.mathjs.org). If math.js disagrees, the question is
   thrown away.
3. If every tier comes up empty, the card says so rather than showing a
   fabricated question.

The badge under each solution tells you which tier answered and how it was
checked.

## Running it

```bash
flutter pub get
dart run build_runner build      # Drift database code
flutter run
```

Requires Flutter 3.47+. iOS builds need a Mac.

```bash
flutter test        # 315 tests
flutter analyze
```

## Layout

```
lib/
├── app/         theme, router — theme tokens come from design/
├── core/        network, Drift database, date service, seeding
├── features/    home · wordle · cat_quant · trivia · pokemon · places
│                animals · games · gym · events · todos · history · settings
└── shared/      the widget set every feature composes from
```

UI never touches Dio. Every feature goes
`widget → Riverpod → repository → service → Dio`, and repositories are
cache-first: today's row is read from the database before anything is fetched,
which is what makes the app work offline.

`design/Daily Ritual.dc.html` is the design canvas the UI is built to — open it
in a browser. `IMPLEMENTATION.md` carries the full spec, the API registry, and
the reasoning behind each decision.

## Status

Phases 1 and 2 are done. Japan of the day, Surprise Me and notifications are
next; see `IMPLEMENTATION.md` for the plan.
