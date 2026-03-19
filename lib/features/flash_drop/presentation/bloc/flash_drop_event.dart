import 'package:equatable/equatable.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/price_update.dart';

sealed class FlashDropEvent extends Equatable {
  const FlashDropEvent();

  @override
  List<Object?> get props => [];
}

class FlashDropStarted extends FlashDropEvent {
  const FlashDropStarted();
}

class PriceUpdated extends FlashDropEvent {
  final PriceUpdate priceUpdate;

  const PriceUpdated(this.priceUpdate);

  @override
  List<Object?> get props => [priceUpdate];
}

class PurchaseRequested extends FlashDropEvent {
  const PurchaseRequested();
}
