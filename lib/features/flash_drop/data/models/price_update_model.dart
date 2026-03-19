import 'package:luxe_drop/features/flash_drop/domain/entities/price_update.dart';

class PriceUpdateModel {
  final double currentPrice;
  final int remainingInventory;

  const PriceUpdateModel({
    required this.currentPrice,
    required this.remainingInventory,
  });

  factory PriceUpdateModel.fromJson(Map<String, dynamic> json) {
    return PriceUpdateModel(
      currentPrice: (json['currentPrice'] as num).toDouble(),
      remainingInventory: json['remainingInventory'] as int,
    );
  }

  PriceUpdate toEntity() {
    return PriceUpdate(
      currentPrice: currentPrice,
      remainingInventory: remainingInventory,
    );
  }
}
