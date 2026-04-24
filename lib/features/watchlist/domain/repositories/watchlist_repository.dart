import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, List<Stock>>> getWatchlist();
  Future<Either<Failure, List<Stock>>> getAvailableStocks();
  Future<Either<Failure, void>> addStock(Stock stock);
  Future<Either<Failure, void>> removeStock(String symbol);
  Future<Either<Failure, void>> reorderStocks(int oldIndex, int newIndex);
}
