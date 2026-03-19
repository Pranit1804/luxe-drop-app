import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';

class LiveChartPainter extends CustomPainter {
  final List<double> historicalPrices;
  final List<double> livePrices;

  // Pre-computed values to avoid re-calculating in paint()
  late final List<double> _allPrices;
  late final double _minPrice;
  late final double _priceRange;
  late final bool _hasData;

  LiveChartPainter({required this.historicalPrices, required this.livePrices}) {
    if (historicalPrices.isEmpty && livePrices.isEmpty) {
      _allPrices = const [];
      _minPrice = 0;
      _priceRange = 0;
      _hasData = false;
    } else {
      _allPrices = historicalPrices + livePrices;
      _minPrice = _allPrices.reduce(min);
      final maxPrice = _allPrices.reduce(max);
      _priceRange = maxPrice - _minPrice;
      _hasData = _allPrices.isNotEmpty && _priceRange > 0;
    }
  }

  // PERF: Pre-allocate static paint objects to avoid GC pressure.
  // Creating 8+ Paint objects per paint() call at 60fps = ~480 allocations/sec.
  static final Paint _gridPaint = Paint()
    ..color = AppTheme.chartGrid
    ..strokeWidth = 0.5;

  static final Paint _linePaint = Paint()
    ..color = AppTheme.chartLine
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // PERF: Replaced MaskFilter.blur with simple wider semi-transparent line.
  // MaskFilter.blur is GPU-expensive (requires extra render pass) and was
  // being applied on every chart repaint (~every 800ms).
  static final Paint _glowPaint = Paint()
    ..color = AppTheme.gold.withValues(alpha: 0.15)
    ..strokeWidth = 8.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _liveLinePaint = Paint()
    ..color = AppTheme.goldLight
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _dotGlow = Paint()
    ..color = AppTheme.gold.withValues(alpha: 0.2);

  static final Paint _dotOuter = Paint()
    ..color = AppTheme.gold;

  static final Paint _dotInner = Paint()
    ..color = AppTheme.scaffoldBackground;

  @override
  void paint(Canvas canvas, Size size) {
    if (!_hasData) return;

    const padding = EdgeInsets.only(top: 16, bottom: 8, left: 0, right: 0);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    _drawGridLines(canvas, size, padding, chartHeight);

    final path = Path();
    final fillPath = Path();

    final totalPoints = _allPrices.length;
    final xStep = chartWidth / (totalPoints - 1).clamp(1, totalPoints);

    for (int i = 0; i < totalPoints; i++) {
      final x = padding.left + i * xStep;
      final y =
          padding.top +
          chartHeight -
          ((_allPrices[i] - _minPrice) / _priceRange * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = padding.left + (i - 1) * xStep;
        final prevY =
            padding.top +
            chartHeight -
            ((_allPrices[i - 1] - _minPrice) / _priceRange * chartHeight);
        final midX = (prevX + x) / 2;

        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    fillPath.lineTo(padding.left + (totalPoints - 1) * xStep, size.height);
    fillPath.close();

    // Fill gradient — must be created per-paint because it depends on size
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, padding.top),
        Offset(0, size.height),
        [AppTheme.chartFill, AppTheme.chartFill.withValues(alpha: 0.0)],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(path, _linePaint);

    if (livePrices.isNotEmpty) {
      final liveStartIndex = historicalPrices.length;
      final livePath = Path();

      for (int i = liveStartIndex; i < totalPoints; i++) {
        final x = padding.left + i * xStep;
        final y =
            padding.top +
            chartHeight -
            ((_allPrices[i] - _minPrice) / _priceRange * chartHeight);

        if (i == liveStartIndex) {
          livePath.moveTo(x, y);
        } else {
          final prevX = padding.left + (i - 1) * xStep;
          final prevY =
              padding.top +
              chartHeight -
              ((_allPrices[i - 1] - _minPrice) / _priceRange * chartHeight);
          final midX = (prevX + x) / 2;
          livePath.cubicTo(midX, prevY, midX, y, x, y);
        }
      }

      // Glow + line drawn with pre-allocated static paints
      canvas.drawPath(livePath, _glowPaint);
      canvas.drawPath(livePath, _liveLinePaint);

      if (totalPoints > 0) {
        final lastX = padding.left + (totalPoints - 1) * xStep;
        final lastY =
            padding.top +
            chartHeight -
            ((_allPrices.last - _minPrice) / _priceRange * chartHeight);
        final lastOffset = Offset(lastX, lastY);

        canvas.drawCircle(lastOffset, 6, _dotGlow);
        canvas.drawCircle(lastOffset, 4, _dotOuter);
        canvas.drawCircle(lastOffset, 2, _dotInner);
      }
    }
  }

  void _drawGridLines(
    Canvas canvas,
    Size size,
    EdgeInsets padding,
    double chartHeight,
  ) {
    const gridCount = 4;

    for (int i = 0; i <= gridCount; i++) {
      final y = padding.top + chartHeight * i / gridCount;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        _gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LiveChartPainter oldDelegate) {
    return oldDelegate.historicalPrices.length != historicalPrices.length ||
        oldDelegate.livePrices.length != livePrices.length ||
        (livePrices.isNotEmpty &&
            oldDelegate.livePrices.isNotEmpty &&
            oldDelegate.livePrices.last != livePrices.last);
  }
}
