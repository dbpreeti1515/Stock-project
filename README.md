# Pulse Watchlist

Pulse Watchlist is a production-style Flutter stock watchlist application built for a trading-company assignment. It uses Clean Architecture, BLoC, Hive persistence, a mock remote data source, and a modular presentation layer to keep the codebase scalable for future real-market integrations.

## Project Overview

The app focuses on a core trader workflow:

- View a curated stock watchlist with symbol, company name, last price, and daily change.
- Reorder symbols with drag-and-drop.
- Add new stocks from a simulated market catalog.
- Remove stocks with confirmation.
- Persist the watchlist locally so the same order and symbols restore after restart.

## Architecture

The project follows strict Clean Architecture:

- `presentation`: Flutter UI, reusable widgets, and `WatchlistBloc`.
- `domain`: pure Dart entities, repository contracts, and use cases.
- `data`: DTO models, local/remote data sources, and repository implementation.
- `core`: shared constants, formatting helpers, and error abstractions.

### Data Flow

`UI -> BLoC -> UseCase -> Repository -> DataSource -> Hive / Mock API`

### Why this structure

- Business logic is isolated from Flutter widgets.
- The repository hides storage/network details from the domain layer.
- Replacing the mock API with a real service later only affects the data layer.
- BLoC keeps state transitions explicit and testable.

## Folder Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── error/
│   └── utils/
├── features/
│   └── watchlist/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── injection_container.dart
└── main.dart
```

## State Management

`WatchlistBloc` exposes the required events:

- `LoadWatchlist`
- `AddStock`
- `RemoveStock`
- `ReorderStocks`

The state is immutable and `Equatable`-based. It tracks:

- screen status (`initial`, `loading`, `success`, `failure`)
- current watchlist items
- available market symbols from the mock API
- transient user-facing messages
- in-flight mutation state for add/remove/reorder actions

## Local Persistence

Hive is used for local persistence. The local data source stores the watchlist as a single ordered payload, which avoids key-order bugs and ensures drag-and-drop order is restored exactly after app restart.

## Mock API

The remote data source simulates a backend with `Future.delayed` and returns realistic JSON-shaped stock payloads. It exposes:

- initial watchlist seed data
- broader market catalog used by the add-stock sheet

## Security and Code Quality Notes

- Stock symbols are normalized to uppercase before persistence.
- Invalid symbols are rejected with repository-level validation.
- Duplicate additions are blocked.
- Exceptions are translated into typed failures instead of leaking raw implementation details to the UI.
- UI widgets stay presentation-only; business rules remain in domain/data layers.

## Setup

1. Install Flutter.
2. Run:

```bash
flutter pub get
```

3. Generate the Hive adapter if needed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Start the app:

```bash
flutter run
```

## Screenshots

Add screenshots here for submission:

- `docs/screenshots/watchlist-overview.png`
- `docs/screenshots/add-stock-sheet.png`
- `docs/screenshots/reorder-state.png`

## Key Decisions and Trade-offs

- Hive was chosen over SharedPreferences because ordering and object persistence are first-class concerns here.
- The mock API remains intentionally deterministic for assignment stability.
- Mutation events trigger a refresh load after completion to keep state derivation centralized and avoid duplicated reconciliation logic in the BLoC.
- The UI is intentionally modular so future work such as symbol search, live quotes, or portfolio grouping can be added without collapsing the architecture.
