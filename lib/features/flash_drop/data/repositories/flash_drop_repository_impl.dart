import 'dart:convert';
import 'dart:isolate';

import 'package:luxe_drop/features/flash_drop/data/datasources/mock_flash_drop_datasource.dart';
import 'package:luxe_drop/features/flash_drop/data/models/historical_bid_model.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/historical_bid.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/price_update.dart';
import 'package:luxe_drop/features/flash_drop/domain/repositories/flash_drop_repository.dart';

class FlashDropRepositoryImpl implements FlashDropRepository {
  final MockFlashDropDatasource _datasource;

  FlashDropRepositoryImpl(this._datasource);

  @override
  Future<List<HistoricalBid>> getHistoricalData() async {
    final rawJson = await _datasource.fetchHistoricalBids();

    final result = await Isolate.run(() {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((e) => HistoricalBidModel.fromJson(e as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    });

    return result;
  }

  @override
  Stream<PriceUpdate> watchPriceUpdates() {
    return _datasource.priceStream().map((model) => model.toEntity());
  }

  @override
  Future<bool> purchaseItem() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }
}
