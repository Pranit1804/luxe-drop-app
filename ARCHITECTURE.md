# Architecture

## Overview

LuxeDrop is a single-screen Flutter app that demonstrates a premium "Flash Drop" Product Detail Page (PDP) with real-time price updates, a custom-painted chart, and a state-driven purchase animation — all at 60+ FPS.

## Folder Structure

We use **feature-first clean architecture** to keep the codebase organized:

```
lib/
├── app.dart                              # MaterialApp, theme
├── main.dart                             # Entry point
├── core/                                 # Shared utilities
│   ├── constants.dart
│   ├── theme/app_theme.dart
│   └── utils/price_formatter.dart
└── features/flash_drop/
    ├── data/                             # External data layer
    │   ├── datasources/                  # Mock WebSocket + asset reader
    │   ├── models/                       # Serializable models
    │   └── repositories/                 # Repo implementation
    ├── domain/                           # Business logic layer
    │   ├── entities/                     # Pure domain objects
    │   ├── repositories/                 # Abstract interface
    │   └── usecases/                     # Single use case per feature
    └── presentation/                     # UI layer
        ├── bloc/                         # FlashDropBloc
        ├── pages/                        # FlashDropPage
        └── widgets/                      # Reusable UI components
```

**Why feature-first?** Each feature (here, `flash_drop`) is self-contained with its own data, domain, and presentation layers. This scales well as features grow and makes code navigation intuitive.

## State Management — BLoC

We chose **BLoC** (Business Logic Component) for its clear uni-directional data flow:

```
Events → BLoC → States → UI
```

### Design Decisions

- **Single BLoC per feature**: `FlashDropBloc` manages historical data loading, live price stream, and purchase flow. Since this is a single-screen feature, one BLoC avoids inter-cubit synchronization complexity.
- **Single use case**: `FlashDropUseCase` sits between the BLoC and repository, housing business logic (purchase validation). The BLoC dispatches to the use case, not the repo directly.
- **Status enum**: `FlashDropStatus` (`loading | loaded | purchasing | purchased | error`) drives the UI state machine cleanly.
- **Error handling**: Errors are surfaced via `SnackBar` — no `Either`/`Failure` abstractions needed for this scope.

### Event Flow

| Event | Trigger | Result |
|---|---|---|
| `FlashDropStarted` | Page init | Loads historical data via isolate, subscribes to live stream |
| `PriceUpdated` | Each 800ms tick | Updates current price, appends to live chart data |
| `PurchaseRequested` | User holds button 2s | Verifies inventory, simulates purchase |

## Isolate Communication

The performance-critical piece is parsing a ~2.8MB JSON file containing 50,000 historical bid entries. This is handled **entirely off the main thread**:

1. `MockFlashDropDatasource.fetchHistoricalBids()` reads the JSON from `assets/historical_bids.json` (simulating a network response).
2. `FlashDropRepositoryImpl.getHistoricalData()` passes the raw JSON string to `Isolate.run()`.
3. Inside the isolate: `jsonDecode` → map to `HistoricalBidModel` → convert to `HistoricalBid` entities.
4. The parsed list is returned to the main isolate — zero UI thread blocking.

**Why `Isolate.run()` over `compute()`?** `Isolate.run` is the modern Dart 2.19+ API. `compute` is effectively a wrapper around it. `Isolate.run` is cleaner and aligns with current Dart best practices.

**Chart optimization**: The 50K data points are downsampled to ~300 points for rendering via a simple LTTB-inspired sampling algorithm. This ensures the `CustomPainter` remains performant while preserving the visual shape of the data.

## Animation Architecture

### 1. Implicit Animation — Price Display

`AnimatedSwitcher` with a custom slide + fade transition. Each new price gets a unique `ValueKey`, triggering the animation. The slide direction (up/down) and color (green/red) are driven by price direction.

### 2. Custom Painter — Live Chart

`LiveChartPainter` draws a Robinhood-style gradient line chart:
- Cubic bezier curves for smooth lines
- Gradient fill below the line
- Live section has a glow effect (gold accent)
- Pulsing dot at the current price point
- Wrapped in `RepaintBoundary` for isolation from other widget rebuilds

### 3. Explicit Animation — Hold to Secure Button

Three-state animation using `AnimationController`:

| State | Visual | Mechanism |
|---|---|---|
| Idle | Gold gradient button, "HOLD TO SECURE" | Static |
| Holding | Progress ring fills over 2s, button glows | `AnimationController.forward()` over 2s |
| Released early | Ring snaps back | `AnimationController.reverse()` |
| Purchasing | Morphs to circular spinner | BLoC state drives UI |
| Success | Green checkmark with elastic scale | `AnimationController` + `Curves.elasticOut` |

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `equatable` | Value equality for BLoC states/events |
| `http` | API client (present for architecture; data is mocked) |
| `intl` | INR currency formatting |
| `google_fonts` | Premium typography (Playfair Display + Inter) |
| `shimmer` | Skeleton loading during data parse |
