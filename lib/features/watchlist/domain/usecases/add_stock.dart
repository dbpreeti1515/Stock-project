import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stock.dart';
import '../repositories/watchlist_repository.dart';

class AddStockUseCase {
  AddStockUseCase(this.repository);

  final WatchlistRepository repository;

  Future<Either<Failure, void>> call(Stock stock) {
    return repository.addStock(stock);
  }
}
