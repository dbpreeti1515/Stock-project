import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/stock.dart';
import '../bloc/watchlist_bloc.dart';
import '../widgets/add_stock_sheet.dart';
import '../widgets/stock_card.dart';
import '../widgets/watchlist_header.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  Future<void> _showAddStockSheet(
    BuildContext context,
    WatchlistState state,
  ) async {
    final existingSymbols = state.stocks.map((stock) => stock.symbol).toSet();
    final availableChoices = state.availableStocks
        .where((stock) => !existingSymbols.contains(stock.symbol))
        .toList(growable: false);

    final selectedStock = await showModalBottomSheet<Stock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddStockSheet(stocks: availableChoices),
    );

    if (selectedStock != null && context.mounted) {
      context.read<WatchlistBloc>().add(AddStock(selectedStock));
    }
  }

  Future<void> _confirmRemove(BuildContext context, Stock stock) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Remove ${stock.symbol}?'),
          content: Text(
            '${stock.name} will be removed from the local watchlist snapshot.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true && context.mounted) {
      context.read<WatchlistBloc>().add(RemoveStock(stock.symbol));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WatchlistBloc, WatchlistState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final horizontalPadding = screenWidth < 600 ? 16.0 : screenWidth * 0.05;
        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

        return Scaffold(
          floatingActionButton: state.status == WatchlistStatus.success
              ? FloatingActionButton.extended(
                  onPressed: state.isMutating
                      ? null
                      : () => _showAddStockSheet(context, state),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Stock'),
                )
              : null,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFE7F8F4), AppColors.background],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      bottomInset,
                    ),
                    child: Column(
                      children: <Widget>[
                        WatchlistHeader(
                          onAddPressed: state.status == WatchlistStatus.success
                              ? () => _showAddStockSheet(context, state)
                              : null,
                        ),
                        if (state.isMutating) ...<Widget>[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                            minHeight: 4,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: AppDurations.medium,
                            child: switch (state.status) {
                              WatchlistStatus.initial ||
                              WatchlistStatus.loading => const _LoadingView(),
                              WatchlistStatus.failure => _FailureView(
                                message:
                                    state.message ??
                                    'Unable to load your watchlist.',
                                onRetry: () => context
                                    .read<WatchlistBloc>()
                                    .add(const LoadWatchlist()),
                              ),
                              WatchlistStatus.success =>
                                state.stocks.isEmpty
                                    ? _EmptyState(
                                        onAddPressed: () =>
                                            _showAddStockSheet(context, state),
                                      )
                                    : _LoadedView(
                                        state: state,
                                        onRemove: (stock) =>
                                            _confirmRemove(context, stock),
                                      ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state, required this.onRemove});

  final WatchlistState state;
  final ValueChanged<Stock> onRemove;

  @override
  Widget build(BuildContext context) {
    final gainers = state.stocks.where((stock) => stock.isPositive).length;
    final laggards = state.stocks.length - gainers;
    final averageMove =
        state.stocks.fold<double>(
          0,
          (sum, stock) => sum + stock.changePercentage,
        ) /
        state.stocks.length;
    final metrics = <Widget>[
      _MetricCard(
        label: 'Symbols',
        value: '${state.stocks.length}',
        detail: 'Persisted locally with Hive',
      ),
      _MetricCard(
        label: 'Avg move',
        value: StockFormatters.change(averageMove),
        detail: '$gainers up / $laggards down',
      ),
      _MetricCard(
        label: 'Available',
        value: '${state.availableStocks.length}',
        detail: 'Mock API catalog',
      ),
    ];

    return LayoutBuilder(
      key: const ValueKey<String>('loaded-watchlist'),
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (
                    var index = 0;
                    index < metrics.length;
                    index++
                  ) ...<Widget>[
                    Expanded(child: metrics[index]),
                    if (index != metrics.length - 1) const SizedBox(width: 12),
                  ],
                ],
              )
            else
              SizedBox(
                height: 145,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: metrics.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 12),
                  itemBuilder: (_, index) => metrics[index],
                ),
              ),
            const SizedBox(height: 18),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: state.stocks.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<WatchlistBloc>().add(
                    ReorderStocks(oldIndex: oldIndex, newIndex: newIndex),
                  );
                },
                itemBuilder: (context, index) {
                  final stock = state.stocks[index];
                  return StockCard(
                    key: ValueKey<String>(stock.symbol),
                    stock: stock,
                    index: index,
                    onRemove: () => onRemove(stock),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 60).clamp(
      200.0,
      240.0,
    );
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey<String>('loading-view'),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey<String>('empty-view'),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.candlestick_chart_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No symbols on the watchlist',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add stocks from the mock market catalog to build a persisted watchlist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first stock'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey<String>('failure-view'),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.danger,
              size: 42,
            ),
            const SizedBox(height: 18),
            const Text(
              'Watchlist unavailable',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
