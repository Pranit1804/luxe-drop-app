import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luxe_drop/core/constants.dart';
import 'package:luxe_drop/features/flash_drop/domain/usecases/flash_drop_usecase.dart';
import 'package:luxe_drop/features/flash_drop/presentation/bloc/flash_drop_event.dart';
import 'package:luxe_drop/features/flash_drop/presentation/bloc/flash_drop_state.dart';

class FlashDropBloc extends Bloc<FlashDropEvent, FlashDropState> {
  final FlashDropUseCase _useCase;
  StreamSubscription? _priceSubscription;

  FlashDropBloc(this._useCase) : super(const FlashDropState()) {
    on<FlashDropStarted>(_onStarted);
    on<PriceUpdated>(_onPriceUpdated);
    on<PurchaseRequested>(_onPurchaseRequested);
  }

  Future<void> _onStarted(
    FlashDropStarted event,
    Emitter<FlashDropState> emit,
  ) async {
    try {
      final historicalData = await _useCase.getHistoricalData();

      final allPrices = historicalData.map((e) => e.price).toList();
      final downsampled = _downsample(
        allPrices,
        AppConstants.chartDownsampleTarget,
      );

      emit(
        state.copyWith(
          status: FlashDropStatus.loaded,
          historicalData: historicalData,
          downsampledHistorical: downsampled,
          currentPrice: historicalData.isNotEmpty
              ? historicalData.last.price
              : 0,
          remainingInventory: 50,
        ),
      );

      _priceSubscription = _useCase.watchPriceUpdates().listen(
        (priceUpdate) => add(PriceUpdated(priceUpdate)),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashDropStatus.error,
          errorMessage: 'Failed to load data. Please try again.',
        ),
      );
    }
  }

  void _onPriceUpdated(PriceUpdated event, Emitter<FlashDropState> emit) {
    final currentLive = state.livePricePoints;
    final List<double> updatedLivePoints;

    // PERF: Use List.of + add instead of spread to reduce intermediate
    // allocations and GC pressure on every 800ms tick.
    if (currentLive.length >= AppConstants.maxLivePricePoints) {
      updatedLivePoints = List<double>.of(
        currentLive.sublist(
          currentLive.length - AppConstants.maxLivePricePoints + 1,
        ),
      )..add(event.priceUpdate.currentPrice);
    } else {
      updatedLivePoints = List<double>.of(currentLive)
        ..add(event.priceUpdate.currentPrice);
    }

    emit(
      state.copyWith(
        previousPrice: state.currentPrice,
        currentPrice: event.priceUpdate.currentPrice,
        remainingInventory: event.priceUpdate.remainingInventory,
        livePricePoints: updatedLivePoints,
      ),
    );
  }

  Future<void> _onPurchaseRequested(
    PurchaseRequested event,
    Emitter<FlashDropState> emit,
  ) async {
    if (state.remainingInventory <= 0) {
      emit(
        state.copyWith(
          status: FlashDropStatus.error,
          errorMessage: 'Item is out of stock!',
        ),
      );

      emit(state.copyWith(status: FlashDropStatus.loaded));
      return;
    }

    emit(state.copyWith(status: FlashDropStatus.purchasing));

    try {
      final success = await _useCase.purchaseItem();
      if (success) {
        emit(state.copyWith(status: FlashDropStatus.purchased));
      } else {
        emit(
          state.copyWith(
            status: FlashDropStatus.error,
            errorMessage: 'Purchase failed. Try again.',
          ),
        );
        emit(state.copyWith(status: FlashDropStatus.loaded));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashDropStatus.error,
          errorMessage: 'Purchase failed. Try again.',
        ),
      );
      emit(state.copyWith(status: FlashDropStatus.loaded));
    }
  }

  static List<double> _downsample(List<double> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    return List.generate(
      targetCount,
      (i) => data[(i * step).floor().clamp(0, data.length - 1)],
    );
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    return super.close();
  }
}
