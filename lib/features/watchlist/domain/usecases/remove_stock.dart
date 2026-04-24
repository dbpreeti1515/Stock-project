import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/watchlist_repository.dart';

class RemoveStockUseCase {
  RemoveStockUseCase(this.repository);

  final WatchlistRepository repository;

  Future<Either<Failure, void>> call(String symbol) {
    return repository.removeStock(symbol);
  }
}
