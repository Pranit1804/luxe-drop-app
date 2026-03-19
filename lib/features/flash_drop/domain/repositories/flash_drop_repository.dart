import 'package:luxe_drop/features/flash_drop/domain/entities/historical_bid.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/price_update.dart';

abstract class FlashDropRepository {
  Future<List<HistoricalBid>> getHistoricalData();

  Stream<PriceUpdate> watchPriceUpdates();

  Future<bool> purchaseItem();
}
