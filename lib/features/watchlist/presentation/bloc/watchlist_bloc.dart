import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stock.dart';
import '../../domain/usecases/add_stock.dart';
import '../../domain/usecases/get_available_stocks.dart';
import '../../domain/usecases/get_watchlist.dart';
import '../../domain/usecases/remove_stock.dart';
import '../../domain/usecases/reorder_stocks.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({
    required this.loadWatchlist,
    required this.getAvailableStocks,
    required this.addStock,
    required this.removeStock,
    required this.reorderStocks,
  }) : super(WatchlistState()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<AddStock>(_onAddStock);
    on<RemoveStock>(_onRemoveStock);
    on<ReorderStocks>(_onReorderStocks);
  }

  final LoadWatchlistUseCase loadWatchlist;
  final GetAvailableStocksUseCase getAvailableStocks;
  final AddStockUseCase addStock;
  final RemoveStockUseCase removeStock;
  final ReorderStocksUseCase reorderStocks;

  List<Stock> _reorderedStocks(List<Stock> stocks, int oldIndex, int newIndex) {
    final updatedStocks = List<Stock>.from(stocks);
    if (oldIndex < 0 ||
        oldIndex >= updatedStocks.length ||
        newIndex < 0 ||
        newIndex > updatedStocks.length) {
      return stocks;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final movedStock = updatedStocks.removeAt(oldIndex);
    updatedStocks.insert(newIndex, movedStock);
    return List<Stock>.unmodifiable(updatedStocks);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading, clearMessage: true));

    final watchlistResult = await loadWatchlist();
    final marketResult = await getAvailableStocks();

    watchlistResult.fold(
      (failure) => emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          message: failure.message,
          isMutating: false,
        ),
      ),
      (stocks) {
        marketResult.fold(
          (failure) => emit(
            state.copyWith(
              status: WatchlistStatus.failure,
              stocks: stocks,
              message: failure.message,
              isMutating: false,
            ),
          ),
          (availableStocks) => emit(
            state.copyWith(
              status: WatchlistStatus.success,
              stocks: stocks,
              availableStocks: availableStocks,
              isMutating: false,
              clearMessage: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddStock(AddStock event, Emitter<WatchlistState> emit) async {
    emit(state.copyWith(isMutating: true, clearMessage: true));
    final result = await addStock(event.stock);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isMutating: false,
          message: failure.message,
          status: state.stocks.isEmpty
              ? WatchlistStatus.failure
              : WatchlistStatus.success,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: WatchlistStatus.success,
          stocks: <Stock>[...state.stocks, event.stock],
          isMutating: false,
          message: '${event.stock.symbol} added to your watchlist.',
        ),
      ),
    );
  }

  Future<void> _onRemoveStock(
    RemoveStock event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, clearMessage: true));
    final result = await removeStock(event.symbol);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isMutating: false,
          message: failure.message,
          status: state.stocks.isEmpty
              ? WatchlistStatus.failure
              : WatchlistStatus.success,
        ),
      ),
      (_) {
        final updatedStocks = state.stocks
            .where((stock) => stock.symbol != event.symbol)
            .toList(growable: false);
        emit(
          state.copyWith(
            status: WatchlistStatus.success,
            stocks: updatedStocks,
            isMutating: false,
            message: '${event.symbol} removed from your watchlist.',
          ),
        );
      },
    );
  }

  Future<void> _onReorderStocks(
    ReorderStocks event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(isMutating: true, clearMessage: true));
    final result = await reorderStocks(event.oldIndex, event.newIndex);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isMutating: false,
          message: failure.message,
          status: WatchlistStatus.success,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: WatchlistStatus.success,
          stocks: _reorderedStocks(
            state.stocks,
            event.oldIndex,
            event.newIndex,
          ),
          isMutating: false,
          message: 'Watchlist order updated.',
        ),
      ),
    );
  }
}
