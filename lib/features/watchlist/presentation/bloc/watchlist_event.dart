part of 'watchlist_bloc.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

class AddStock extends WatchlistEvent {
  const AddStock(this.stock);

  final Stock stock;

  @override
  List<Object> get props => <Object>[stock];
}

class RemoveStock extends WatchlistEvent {
  const RemoveStock(this.symbol);

  final String symbol;

  @override
  List<Object> get props => <Object>[symbol];
}

class ReorderStocks extends WatchlistEvent {
  const ReorderStocks({
    required this.oldIndex,
    required this.newIndex,
  });

  final int oldIndex;
  final int newIndex;

  @override
  List<Object> get props => <Object>[oldIndex, newIndex];
}
