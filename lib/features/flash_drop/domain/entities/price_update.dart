import 'package:equatable/equatable.dart';

class PriceUpdate extends Equatable {
  final double currentPrice;
  final int remainingInventory;

  const PriceUpdate({
    required this.currentPrice,
    required this.remainingInventory,
  });

  @override
  List<Object?> get props => [currentPrice, remainingInventory];
}
