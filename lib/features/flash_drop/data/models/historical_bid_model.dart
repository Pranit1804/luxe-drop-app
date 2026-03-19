import 'package:luxe_drop/features/flash_drop/domain/entities/historical_bid.dart';

class HistoricalBidModel {
  final String timestamp;
  final double price;

  const HistoricalBidModel({required this.timestamp, required this.price});

  factory HistoricalBidModel.fromJson(Map<String, dynamic> json) {
    return HistoricalBidModel(
      timestamp: json['timestamp'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  HistoricalBid toEntity() {
    return HistoricalBid(timestamp: DateTime.parse(timestamp), price: price);
  }
}
