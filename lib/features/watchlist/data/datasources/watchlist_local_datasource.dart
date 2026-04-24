import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/stock_model.dart';

abstract class WatchlistLocalDataSource {
  Future<List<StockModel>> getWatchlist();
  Future<void> saveWatchlist(List<StockModel> stocks);
  Future<void> addStock(StockModel stock);
  Future<void> removeStock(String symbol);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  WatchlistLocalDataSourceImpl(this.box);

  static const String boxName = 'watchlist_box';
  static const String watchlistKey = 'watchlist_items';

  final Box<List<dynamic>> box;

  @override
  Future<List<StockModel>> getWatchlist() async {
    try {
      final List<dynamic>? storedValue = box.get(watchlistKey);
      if (storedValue == null) {
        return <StockModel>[];
      }
      if (storedValue.any((item) => item is! StockModel)) {
        throw const CacheException('Corrupted watchlist payload.');
      }
      return storedValue.cast<StockModel>().toList(growable: false);
    } catch (error) {
      if (error is CacheException) {
        rethrow;
      }
      throw CacheException('Failed to read watchlist from local storage.');
    }
  }

  @override
  Future<void> saveWatchlist(List<StockModel> stocks) async {
    try {
      await box.put(watchlistKey, List<dynamic>.from(stocks));
    } catch (_) {
      throw const CacheException('Failed to persist watchlist.');
    }
  }

  @override
  Future<void> addStock(StockModel stock) async {
    final current = await getWatchlist();
    final updated = List<StockModel>.from(current)..add(stock);
    await saveWatchlist(updated);
  }

  @override
  Future<void> removeStock(String symbol) async {
    final current = await getWatchlist();
    final updated = current
        .where((stock) => stock.symbol != symbol)
        .toList(growable: false);
    await saveWatchlist(updated);
  }
}
