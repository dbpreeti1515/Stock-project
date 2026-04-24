import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import 'features/watchlist/data/models/stock_model.dart';
import 'features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'features/watchlist/domain/repositories/watchlist_repository.dart';
import 'features/watchlist/domain/usecases/add_stock.dart';
import 'features/watchlist/domain/usecases/get_available_stocks.dart';
import 'features/watchlist/domain/usecases/get_watchlist.dart';
import 'features/watchlist/domain/usecases/remove_stock.dart';
import 'features/watchlist/domain/usecases/reorder_stocks.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<WatchlistBloc>()) {
    return;
  }

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(StockModelAdapter().typeId)) {
    Hive.registerAdapter(StockModelAdapter());
  }
  final watchlistBox = await Hive.openBox<List<dynamic>>(
    WatchlistLocalDataSourceImpl.boxName,
  );

  sl.registerLazySingleton<Box<List<dynamic>>>(() => watchlistBox);

  sl.registerLazySingleton<WatchlistRemoteDataSource>(
    WatchlistRemoteDataSourceImpl.new,
  );
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WatchlistRepository>(
    () =>
        WatchlistRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoadWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableStocksUseCase(sl()));
  sl.registerLazySingleton(() => AddStockUseCase(sl()));
  sl.registerLazySingleton(() => RemoveStockUseCase(sl()));
  sl.registerLazySingleton(() => ReorderStocksUseCase(sl()));

  sl.registerFactory(
    () => WatchlistBloc(
      loadWatchlist: sl(),
      getAvailableStocks: sl(),
      addStock: sl(),
      removeStock: sl(),
      reorderStocks: sl(),
    ),
  );
}
