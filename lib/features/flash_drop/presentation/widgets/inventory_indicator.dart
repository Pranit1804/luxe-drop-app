import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';

class InventoryIndicator extends StatelessWidget {
  final int remainingInventory;

  const InventoryIndicator({super.key, required this.remainingInventory});

  Color get _statusColor {
    if (remainingInventory <= 5) return AppTheme.priceRed;
    if (remainingInventory <= 15) return const Color(0xFFFF9800);
    return AppTheme.textSecondary;
  }

  String get _urgencyText {
    if (remainingInventory <= 0) return 'SOLD OUT';
    if (remainingInventory <= 5) return 'ALMOST GONE';
    if (remainingInventory <= 15) return 'SELLING FAST';
    return 'IN STOCK';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: remainingInventory <= 5
              ? AppTheme.priceRed.withValues(alpha: 0.3)
              : AppTheme.dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (remainingInventory <= 5)
                  BoxShadow(
                    color: AppTheme.priceRed.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _urgencyText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _statusColor,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // PERF: Replaced AnimatedSwitcher (which mounts/unmounts widget
          // subtrees with ScaleTransition + FadeTransition, creating new
          // animation controllers every inventory change) with a simple
          // Text widget. The BlocSelector already gates rebuilds to only
          // occur when remainingInventory changes.
          Text(
            '$remainingInventory left',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
