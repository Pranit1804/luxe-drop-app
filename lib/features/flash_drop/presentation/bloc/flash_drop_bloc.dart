import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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

      emit(
        state.copyWith(
          status: FlashDropStatus.loaded,
          historicalData: historicalData,
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
    final updatedLivePoints = [
      ...state.livePricePoints,
      event.priceUpdate.currentPrice,
    ];

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

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    return super.close();
  }
}
