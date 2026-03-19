import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';

class ProductSpecs extends StatefulWidget {
  const ProductSpecs({super.key});

  @override
  State<ProductSpecs> createState() => _ProductSpecsState();
}

class _ProductSpecsState extends State<ProductSpecs>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THE DETAILS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 2.0,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            height: _isExpanded ? null : 0,
            child: Opacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpecRow(context, 'Material', 'Stainless Steel'),
                    _buildSpecRow(
                      context,
                      'Bezel',
                      'Octagonal, polished and satin-brushed',
                    ),
                    _buildSpecRow(
                      context,
                      'Dial',
                      'Olive green sunburst, horizontally embossed',
                    ),
                    _buildSpecRow(
                      context,
                      'Movement',
                      'Caliber 26-330 S C, Self-winding',
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'WHY IT\'S RARE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 2.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The legendary reference 5711/1A-014 features the final-run olive green sunburst dial—released exclusively for a single production year before the model\'s complete discontinuation. With only a handful ever made public, this allocation of unworn, vault-kept condition pieces represents an incredibly scarce collector\'s apex.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppTheme.textPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
