class AppConstants {
  AppConstants._();

  static const Duration tickInterval = Duration(milliseconds: 800);

  static const Duration holdDuration = Duration(seconds: 2);

  static const int historicalDataSize = 50000;

  static const Duration purchaseVerificationDelay = Duration(
    milliseconds: 1500,
  );

  static const double basePrice = 125000.0;

  static const double maxPriceFluctuation = 1500.0;

  static const int initialInventory = 50;

  static const double inventoryDecrementProbability = 0.3;

  static const String historicalBidsAssetPath = 'assets/historical_bids.json';

  static const int maxLivePricePoints = 100;

  static const int chartDownsampleTarget = 300;
}
