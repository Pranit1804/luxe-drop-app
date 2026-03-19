import 'package:equatable/equatable.dart';

class HistoricalBid extends Equatable {
  final DateTime timestamp;
  final double price;

  const HistoricalBid({required this.timestamp, required this.price});

  @override
  List<Object?> get props => [timestamp, price];
}
