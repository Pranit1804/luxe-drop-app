import 'package:equatable/equatable.dart';
import 'package:luxe_drop/features/flash_drop/domain/entities/historical_bid.dart';

enum FlashDropStatus { loading, loaded, purchasing, purchased, error }

class FlashDropState extends Equatable {
  final FlashDropStatus status;
  final List<HistoricalBid> historicalData;
  final List<double> livePricePoints;
  final double currentPrice;
  final double? previousPrice;
  final int remainingInventory;
  final String? errorMessage;

  const FlashDropState({
    this.status = FlashDropStatus.loading,
    this.historicalData = const [],
    this.livePricePoints = const [],
    this.currentPrice = 0,
    this.previousPrice,
    this.remainingInventory = 0,
    this.errorMessage,
  });

  bool get isPriceUp => previousPrice != null && currentPrice >= previousPrice!;

  FlashDropState copyWith({
    FlashDropStatus? status,
    List<HistoricalBid>? historicalData,
    List<double>? livePricePoints,
    double? currentPrice,
    double? previousPrice,
    int? remainingInventory,
    String? errorMessage,
  }) {
    return FlashDropState(
      status: status ?? this.status,
      historicalData: historicalData ?? this.historicalData,
      livePricePoints: livePricePoints ?? this.livePricePoints,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      remainingInventory: remainingInventory ?? this.remainingInventory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    historicalData,
    livePricePoints,
    currentPrice,
    previousPrice,
    remainingInventory,
    errorMessage,
  ];
}
