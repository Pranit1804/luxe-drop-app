import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/live_chart_painter.dart';

class LiveChart extends StatelessWidget {
  final List<double> historicalPrices;
  final List<double> livePrices;

  const LiveChart({
    super.key,
    required this.historicalPrices,
    required this.livePrices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PRICE HISTORY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 2.0,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.priceGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.priceGreen.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5,
                  color: AppTheme.priceGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: LiveChartPainter(
                  historicalPrices: historicalPrices,
                  livePrices: livePrices,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
