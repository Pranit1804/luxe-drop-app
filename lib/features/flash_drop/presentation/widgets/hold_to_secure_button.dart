import 'package:flutter/material.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';

class HoldToSecureButton extends StatefulWidget {
  final VoidCallback onPurchaseConfirmed;
  final bool isPurchasing;
  final bool isPurchased;
  final bool isDisabled;

  const HoldToSecureButton({
    super.key,
    required this.onPurchaseConfirmed,
    this.isPurchasing = false,
    this.isPurchased = false,
    this.isDisabled = false,
  });

  @override
  State<HoldToSecureButton> createState() => _HoldToSecureButtonState();
}

class _HoldToSecureButtonState extends State<HoldToSecureButton>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      reverseDuration: const Duration(milliseconds: 500),
    );

    _progressAnimation = CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPurchaseConfirmed();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HoldToSecureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPurchased && !oldWidget.isPurchased) {
      _successController.forward();
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    if (widget.isPurchasing || widget.isPurchased || widget.isDisabled) return;
    setState(() => _isHolding = true);
    _holdController.forward();
  }

  void _onPressEnd() {
    if (widget.isPurchasing || widget.isPurchased) return;
    setState(() => _isHolding = false);
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.isPurchased) {
      child = KeyedSubtree(
        key: const ValueKey('purchased'),
        child: _buildSuccessState(),
      );
    } else if (widget.isPurchasing) {
      child = KeyedSubtree(
        key: const ValueKey('purchasing'),
        child: _buildPurchasingState(),
      );
    } else {
      child = KeyedSubtree(
        key: const ValueKey('idle'),
        child: _buildIdleHoldState(),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildIdleHoldState() {
    return GestureDetector(
      onPanDown: (_) => _onPressStart(),
      onPanCancel: () => _onPressEnd(),
      onPanEnd: (_) => _onPressEnd(),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final progress = _progressAnimation.value;
          return AnimatedScale(
            scale: _isHolding ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [AppTheme.gold, AppTheme.goldDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(
                      alpha: 0.12 + progress * 0.16,
                    ),
                    blurRadius: 10 + progress * 14,
                    spreadRadius: progress * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.4),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Text(
                    _isHolding ? 'SECURING...' : 'HOLD TO SECURE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.scaffoldBackground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchasingState() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(colors: [AppTheme.gold, AppTheme.goldDark]),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.scaffoldBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + _scaleAnimation.value * 0.2,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                colors: [
                  AppTheme.priceGreen,
                  AppTheme.priceGreen.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.priceGreen.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24 * _scaleAnimation.value,
                ),
                const SizedBox(width: 10),
                Text(
                  'SECURED',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
