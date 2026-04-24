import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock.dart';
import '../repositories/watchlist_repository.dart';

class GetAvailableStocksUseCase {
  GetAvailableStocksUseCase(this.repository);

  final WatchlistRepository repository;

  Future<Either<Failure, List<Stock>>> call() {
    return repository.getAvailableStocks();
  }
}
