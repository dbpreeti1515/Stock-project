part of 'watchlist_bloc.dart';

enum WatchlistStatus { initial, loading, success, failure }

class WatchlistState extends Equatable {
  WatchlistState({
    this.status = WatchlistStatus.initial,
    List<Stock> stocks = const <Stock>[],
    List<Stock> availableStocks = const <Stock>[],
    this.message,
    this.isMutating = false,
  })  : stocks = List<Stock>.unmodifiable(stocks),
        availableStocks = List<Stock>.unmodifiable(availableStocks);

  final WatchlistStatus status;
  final List<Stock> stocks;
  final List<Stock> availableStocks;
  final String? message;
  final bool isMutating;

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<Stock>? stocks,
    List<Stock>? availableStocks,
    String? message,
    bool? isMutating,
    bool clearMessage = false,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      stocks: stocks ?? this.stocks,
      availableStocks: availableStocks ?? this.availableStocks,
      message: clearMessage ? null : (message ?? this.message),
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        stocks,
        availableStocks,
        message,
        isMutating,
      ];
}
