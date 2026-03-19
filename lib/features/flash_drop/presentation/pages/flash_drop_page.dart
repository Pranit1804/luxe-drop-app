import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luxe_drop/core/theme/app_theme.dart';
import 'package:luxe_drop/features/flash_drop/data/datasources/mock_flash_drop_datasource.dart';
import 'package:luxe_drop/features/flash_drop/data/repositories/flash_drop_repository_impl.dart';
import 'package:luxe_drop/features/flash_drop/domain/usecases/flash_drop_usecase.dart';
import 'package:luxe_drop/features/flash_drop/presentation/bloc/flash_drop_bloc.dart';
import 'package:luxe_drop/features/flash_drop/presentation/bloc/flash_drop_event.dart';
import 'package:luxe_drop/features/flash_drop/presentation/bloc/flash_drop_state.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/hold_to_secure_button.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/inventory_indicator.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/live_chart.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/price_display.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/product_header.dart';
import 'package:luxe_drop/features/flash_drop/presentation/widgets/product_specs.dart';

class FlashDropPage extends StatelessWidget {
  const FlashDropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final datasource = MockFlashDropDatasource();
        final repository = FlashDropRepositoryImpl(datasource);
        final useCase = FlashDropUseCase(repository);
        return FlashDropBloc(useCase)..add(const FlashDropStarted());
      },
      child: const _FlashDropView(),
    );
  }
}

class _FlashDropView extends StatelessWidget {
  const _FlashDropView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond_rounded, color: AppTheme.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              'LUXE DROP',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.gold,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<FlashDropBloc, FlashDropState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == FlashDropStatus.error,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppTheme.priceRed.withValues(alpha: 0.9),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FlashDropStatus.loading) {
            return _buildShimmerLoading(context);
          }
          return _buildLoadedContent(context, state);
        },
      ),
      bottomNavigationBar: BlocBuilder<FlashDropBloc, FlashDropState>(
        builder: (context, state) {
          if (state.status == FlashDropStatus.loading) {
            return _buildShimmerBottomBar(context);
          }
          return _buildBottomBar(context, state);
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmerBase,
      highlightColor: AppTheme.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 28,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, FlashDropState state) {
    final downsampledHistorical = _downsample(
      state.historicalData.map((e) => e.price).toList(),
      300,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const ProductHeader(),
          const SizedBox(height: 32),
          PriceDisplay(
            currentPrice: state.currentPrice,
            previousPrice: state.previousPrice,
          ),
          const SizedBox(height: 16),
          InventoryIndicator(remainingInventory: state.remainingInventory),
          const SizedBox(height: 32),
          LiveChart(
            historicalPrices: downsampledHistorical,
            livePrices: state.livePricePoints,
          ),
          const SizedBox(height: 32),
          const ProductSpecs(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildShimmerBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Shimmer.fromColors(
            baseColor: AppTheme.shimmerBase,
            highlightColor: AppTheme.shimmerHighlight,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, FlashDropState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: HoldToSecureButton(
            onPurchaseConfirmed: () {
              context.read<FlashDropBloc>().add(const PurchaseRequested());
            },
            isPurchasing: state.status == FlashDropStatus.purchasing,
            isPurchased: state.status == FlashDropStatus.purchased,
            isDisabled: state.remainingInventory <= 0,
          ),
        ),
      ),
    );
  }

  List<double> _downsample(List<double> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    return List.generate(
      targetCount,
      (i) => data[(i * step).floor().clamp(0, data.length - 1)],
    );
  }
}
