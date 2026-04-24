import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/stock.dart';

class StockCard extends StatelessWidget {
  const StockCard({
    super.key,
    required this.stock,
    required this.index,
    required this.onRemove,
  });

  final Stock stock;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final trendColor = stock.isPositive ? AppColors.success : AppColors.danger;
    final trendBackground = trendColor.withValues(alpha: 0.10);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.98, end: 1),
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 460;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: isCompact
                ? _CompactStockCardBody(
                    stock: stock,
                    index: index,
                    trendColor: trendColor,
                    trendBackground: trendBackground,
                    onRemove: onRemove,
                  )
                : _DefaultStockCardBody(
                    stock: stock,
                    index: index,
                    trendColor: trendColor,
                    trendBackground: trendBackground,
                    onRemove: onRemove,
                  ),
          );
        },
      ),
    );
  }
}

class _DefaultStockCardBody extends StatelessWidget {
  const _DefaultStockCardBody({
    required this.stock,
    required this.index,
    required this.trendColor,
    required this.trendBackground,
    required this.onRemove,
  });

  final Stock stock;
  final int index;
  final Color trendColor;
  final Color trendBackground;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StockSymbolBadge(symbol: stock.symbol),
        const SizedBox(width: 16),
        Expanded(
          child: _StockIdentity(
            stock: stock,
            trendColor: trendColor,
            trendBackground: trendBackground,
          ),
        ),
        const SizedBox(width: 12),
        _StockActions(
          stock: stock,
          index: index,
          onRemove: onRemove,
          compact: false,
        ),
      ],
    );
  }
}

class _CompactStockCardBody extends StatelessWidget {
  const _CompactStockCardBody({
    required this.stock,
    required this.index,
    required this.trendColor,
    required this.trendBackground,
    required this.onRemove,
  });

  final Stock stock;
  final int index;
  final Color trendColor;
  final Color trendBackground;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StockSymbolBadge(symbol: stock.symbol),
            const SizedBox(width: 14),
            Expanded(
              child: _StockIdentity(
                stock: stock,
                trendColor: trendColor,
                trendBackground: trendBackground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _StockActions(
          stock: stock,
          index: index,
          onRemove: onRemove,
          compact: true,
        ),
      ],
    );
  }
}

class _StockSymbolBadge extends StatelessWidget {
  const _StockSymbolBadge({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.substring(0, symbol.length >= 3 ? 3 : symbol.length),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _StockIdentity extends StatelessWidget {
  const _StockIdentity({
    required this.stock,
    required this.trendColor,
    required this.trendBackground,
  });

  final Stock stock;
  final Color trendColor;
  final Color trendBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              stock.symbol,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: trendBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                StockFormatters.change(stock.changePercentage),
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          stock.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StockActions extends StatelessWidget {
  const _StockActions({
    required this.stock,
    required this.index,
    required this.onRemove,
    required this.compact,
  });

  final Stock stock;
  final int index;
  final VoidCallback onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (compact)
        Expanded(
          child: Text(
            StockFormatters.currency(stock.price),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      else
        Text(
          StockFormatters.currency(stock.price),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      if (!compact) const SizedBox(height: 6),
      IconButton(
        tooltip: 'Remove ${stock.symbol}',
        onPressed: onRemove,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.panelMuted,
          foregroundColor: AppColors.danger,
        ),
        icon: const Icon(Icons.delete_outline_rounded),
      ),
      ReorderableDragStartListener(
        index: index,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.drag_indicator_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ];

    if (compact) {
      return Row(children: actions);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: actions,
    );
  }
}
