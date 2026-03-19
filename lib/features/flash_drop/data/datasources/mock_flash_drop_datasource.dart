import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:luxe_drop/core/constants.dart';
import 'package:luxe_drop/features/flash_drop/data/models/price_update_model.dart';

class MockFlashDropDatasource {
  final _random = Random();
  double _currentPrice = AppConstants.basePrice;
  int _remainingInventory = AppConstants.initialInventory;

  Stream<PriceUpdateModel> priceStream() {
    return Stream.periodic(AppConstants.tickInterval, (_) {
      final change =
          (_random.nextDouble() * 2 - 1) * AppConstants.maxPriceFluctuation;
      _currentPrice = (_currentPrice + change).clamp(80000.0, 250000.0);

      if (_remainingInventory > 0 &&
          _random.nextDouble() < AppConstants.inventoryDecrementProbability) {
        _remainingInventory--;
      }

      return PriceUpdateModel(
        currentPrice: _currentPrice,
        remainingInventory: _remainingInventory,
      );
    });
  }

  Future<String> fetchHistoricalBids() async {
    return rootBundle.loadString(AppConstants.historicalBidsAssetPath);
  }
}
