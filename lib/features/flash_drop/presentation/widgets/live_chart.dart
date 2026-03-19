import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/live_chart_painter.dart';

/// PERF: Converted to StatefulWidget so we can cache the static header
/// widgets and the Container decoration. Only the CustomPaint child changes
/// when livePrices update, avoiding rebuild of the entire Container + Row.
class LiveChart extends StatefulWidget {
  final List<double> historicalPrices;
  final List<double> livePrices;

  const LiveChart({
    super.key,
    required this.historicalPrices,
    required this.livePrices,
  });

  @override
  State<LiveChart> createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  // Cache the decoration to avoid re-creating BoxDecoration on every build
  static final _containerDecoration = BoxDecoration(
    color: AppTheme.cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.dividerColor, width: 0.5),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: _containerDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Static header — never changes, so build once
          _ChartHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: LiveChartPainter(
                  historicalPrices: widget.historicalPrices,
                  livePrices: widget.livePrices,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted static chart header so it can be cached and never rebuilds.
class _ChartHeader extends StatelessWidget {
  // Cache decorations and styles as static finals
  static final _dotDecoration = BoxDecoration(
    color: AppTheme.priceGreen,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AppTheme.priceGreen.withValues(alpha: 0.5),
        blurRadius: 4,
        spreadRadius: 1,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'PRICE HISTORY',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 2.0,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Container(width: 8, height: 8, decoration: _dotDecoration),
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
    );
  }
}
