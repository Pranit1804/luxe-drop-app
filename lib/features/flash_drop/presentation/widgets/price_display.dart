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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: Offset(0, _isPriceUp ? 0.3 : -0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            PriceFormatter.format(currentPrice),
            key: ValueKey(currentPrice),
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: priceColor),
          ),
        ),
        if (changeAmount != null) ...[
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey(changeAmount),
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
