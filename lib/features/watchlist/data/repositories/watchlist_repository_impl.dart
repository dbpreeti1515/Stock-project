import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../datasources/watchlist_remote_datasource.dart';
import '../models/stock_model.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final WatchlistRemoteDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;

  static final RegExp _symbolPattern = RegExp(r'^[A-Z.]{1,10}$');

  @override
  Future<Either<Failure, List<Stock>>> getWatchlist() async {
    try {
      final localStocks = await localDataSource.getWatchlist();
      if (localStocks.isNotEmpty) {
        return Right(localStocks);
      }

      final seededStocks = await remoteDataSource.getInitialWatchlist();
      await localDataSource.saveWatchlist(seededStocks);
      return Right(seededStocks);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(CacheFailure('Unexpected failure while loading watchlist.'));
    }
  }

  @override
  Future<Either<Failure, List<Stock>>> getAvailableStocks() async {
    try {
      final stocks = await remoteDataSource.getMarketStocks();
      return Right(stocks);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Unexpected failure while loading market data.'));
    }
  }

  @override
  Future<Either<Failure, void>> addStock(Stock stock) async {
    final normalizedSymbol = stock.symbol.trim().toUpperCase();
    if (!_symbolPattern.hasMatch(normalizedSymbol)) {
      return const Left(ValidationFailure('Only valid stock symbols can be added.'));
    }

    try {
      final currentStocks = await localDataSource.getWatchlist();
      final exists = currentStocks.any((item) => item.symbol == normalizedSymbol);
      if (exists) {
        return const Left(ValidationFailure('This stock is already on your watchlist.'));
      }

      await localDataSource.addStock(
        StockModel.fromEntity(
          stock.copyWith(symbol: normalizedSymbol),
        ),
      );
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(CacheFailure('Unexpected failure while adding the stock.'));
    }
  }

  @override
  Future<Either<Failure, void>> removeStock(String symbol) async {
    try {
      await localDataSource.removeStock(symbol.trim().toUpperCase());
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(CacheFailure('Unexpected failure while removing the stock.'));
    }
  }

  @override
  Future<Either<Failure, void>> reorderStocks(int oldIndex, int newIndex) async {
    try {
      final stocks = (await localDataSource.getWatchlist()).toList(growable: true);
      if (oldIndex < 0 ||
          oldIndex >= stocks.length ||
          newIndex < 0 ||
          newIndex > stocks.length) {
        return const Left(ValidationFailure('Unable to reorder the watchlist.'));
      }

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final movedStock = stocks.removeAt(oldIndex);
      stocks.insert(newIndex, movedStock);
      await localDataSource.saveWatchlist(stocks);
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return const Left(CacheFailure('Unexpected failure while reordering the watchlist.'));
    }
  }
}
