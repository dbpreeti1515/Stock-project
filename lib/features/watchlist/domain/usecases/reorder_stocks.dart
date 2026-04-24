import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/watchlist_repository.dart';

class ReorderStocksUseCase {
  ReorderStocksUseCase(this.repository);

  final WatchlistRepository repository;

  Future<Either<Failure, void>> call(int oldIndex, int newIndex) {
    return repository.reorderStocks(oldIndex, newIndex);
  }
}
