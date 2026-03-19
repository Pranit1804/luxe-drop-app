import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';
import 'package:luxe_drop/core/utils/price_formatter.dart';

class PriceDisplay extends StatelessWidget {
  final double currentPrice;
  final double? previousPrice;

  const PriceDisplay({
    super.key,
    required this.currentPrice,
    this.previousPrice,
  });

  bool get _isPriceUp =>
      previousPrice == null || currentPrice >= previousPrice!;

  @override
  Widget build(BuildContext context) {
    final priceColor = previousPrice == null
        ? AppTheme.textPrimary
        : _isPriceUp
        ? AppTheme.priceGreen
        : AppTheme.priceRed;

    final changeAmount = previousPrice != null
        ? currentPrice - previousPrice!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT PRICE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 2.0,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        // PERF: Use AnimatedDefaultTextStyle instead of AnimatedSwitcher.
        // AnimatedSwitcher creates, mounts, and unmounts an entire widget
        // subtree on every price tick (800ms) with SlideTransition +
        // FadeTransition + CurvedAnimation objects. AnimatedDefaultTextStyle
        // is an implicit animation that only interpolates the text style
        // (no widget tree churn).
        RepaintBoundary(
          child: _AnimatedPrice(
            price: currentPrice,
            color: priceColor,
            isPriceUp: _isPriceUp,
          ),
        ),
        if (changeAmount != null) ...[
          const SizedBox(height: 4),
          // PERF: Simplified from AnimatedSwitcher with FadeTransition to
          // just an AnimatedSwitcher with default crossFade. Much lighter.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey(changeAmount.toStringAsFixed(0)),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPriceUp
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: priceColor,
                  size: 20,
                ),
                Text(
                  PriceFormatter.formatChange(changeAmount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: priceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Lightweight price text with animated color. Uses AnimatedDefaultTextStyle
/// to avoid full widget tree teardown/rebuild on every 800ms price tick.
class _AnimatedPrice extends StatelessWidget {
  final double price;
  final Color color;
  final bool isPriceUp;

  const _AnimatedPrice({
    required this.price,
    required this.color,
    required this.isPriceUp,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.displayLarge ??
        const TextStyle(fontSize: 42, fontWeight: FontWeight.w700);

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: baseStyle.copyWith(color: color),
      child: Text(
        PriceFormatter.format(price),
        key: ValueKey(price.toStringAsFixed(0)),
      ),
    );
  }
}
