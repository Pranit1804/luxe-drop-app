import 'package:luxe_drop/features/flash_drop/domain/entities/historical_bid.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/price_update.dart';
import 'package:luxe_drop/features/flash_drop/domain/repositories/flash_drop_repository.dart';

class FlashDropUseCase {
  final FlashDropRepository _repository;

  FlashDropUseCase(this._repository);

  Future<List<HistoricalBid>> getHistoricalData() {
    return _repository.getHistoricalData();
  }

  Stream<PriceUpdate> watchPriceUpdates() {
    return _repository.watchPriceUpdates();
  }

  Future<bool> purchaseItem() async {
    return _repository.purchaseItem();
  }
}
