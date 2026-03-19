import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';

class LiveChartPainter extends CustomPainter {
  final List<double> historicalPrices;
  final List<double> livePrices;

  LiveChartPainter({required this.historicalPrices, required this.livePrices});

  @override
  void paint(Canvas canvas, Size size) {
    if (historicalPrices.isEmpty && livePrices.isEmpty) return;

    final allPrices = [...historicalPrices, ...livePrices];
    if (allPrices.isEmpty) return;

    final minPrice = allPrices.reduce(min);
    final maxPrice = allPrices.reduce(max);
    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;

    const padding = EdgeInsets.only(top: 16, bottom: 8, left: 0, right: 0);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    _drawGridLines(canvas, size, padding, chartHeight, minPrice, priceRange);

    final path = Path();
    final fillPath = Path();

    final totalPoints = allPrices.length;
    final xStep = chartWidth / (totalPoints - 1).clamp(1, totalPoints);

    for (int i = 0; i < totalPoints; i++) {
      final x = padding.left + i * xStep;
      final y =
          padding.top +
          chartHeight -
          ((allPrices[i] - minPrice) / priceRange * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = padding.left + (i - 1) * xStep;
        final prevY =
            padding.top +
            chartHeight -
            ((allPrices[i - 1] - minPrice) / priceRange * chartHeight);
        final midX = (prevX + x) / 2;

        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    fillPath.lineTo(padding.left + (totalPoints - 1) * xStep, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, padding.top),
        Offset(0, size.height),
        [AppTheme.chartFill, AppTheme.chartFill.withValues(alpha: 0.0)],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppTheme.chartLine
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    if (livePrices.isNotEmpty) {
      final liveStartIndex = historicalPrices.length;
      final livePath = Path();

      for (int i = liveStartIndex; i < totalPoints; i++) {
        final x = padding.left + i * xStep;
        final y =
            padding.top +
            chartHeight -
            ((allPrices[i] - minPrice) / priceRange * chartHeight);

        if (i == liveStartIndex) {
          livePath.moveTo(x, y);
        } else {
          final prevX = padding.left + (i - 1) * xStep;
          final prevY =
              padding.top +
              chartHeight -
              ((allPrices[i - 1] - minPrice) / priceRange * chartHeight);
          final midX = (prevX + x) / 2;
          livePath.cubicTo(midX, prevY, midX, y, x, y);
        }
      }

      final glowPaint = Paint()
        ..color = AppTheme.gold.withValues(alpha: 0.3)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(livePath, glowPaint);

      final liveLinePaint = Paint()
        ..color = AppTheme.goldLight
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(livePath, liveLinePaint);

      if (totalPoints > 0) {
        final lastX = padding.left + (totalPoints - 1) * xStep;
        final lastY =
            padding.top +
            chartHeight -
            ((allPrices.last - minPrice) / priceRange * chartHeight);

        canvas.drawCircle(
          Offset(lastX, lastY),
          6,
          Paint()
            ..color = AppTheme.gold.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        canvas.drawCircle(
          Offset(lastX, lastY),
          4,
          Paint()..color = AppTheme.gold,
        );

        canvas.drawCircle(
          Offset(lastX, lastY),
          2,
          Paint()..color = AppTheme.scaffoldBackground,
        );
      }
    }
  }

  void _drawGridLines(
    Canvas canvas,
    Size size,
    EdgeInsets padding,
    double chartHeight,
    double minPrice,
    double priceRange,
  ) {
    const gridCount = 4;
    final gridPaint = Paint()
      ..color = AppTheme.chartGrid
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridCount; i++) {
      final y = padding.top + chartHeight * i / gridCount;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
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
