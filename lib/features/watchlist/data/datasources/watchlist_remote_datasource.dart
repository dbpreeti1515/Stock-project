import '../../../../core/error/exceptions.dart';
import '../models/stock_model.dart';

abstract class WatchlistRemoteDataSource {
  Future<List<StockModel>> getInitialWatchlist();
  Future<List<StockModel>> getMarketStocks();
}

class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  static final List<Map<String, dynamic>> _mockResponse =
      <Map<String, dynamic>>[
        {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'price': 191.24,
          'changePercentage': 1.42,
        },
        {
          'symbol': 'MSFT',
          'name': 'Microsoft Corp.',
          'price': 427.66,
          'changePercentage': 0.84,
        },
        {
          'symbol': 'NVDA',
          'name': 'NVIDIA Corp.',
          'price': 944.12,
          'changePercentage': 3.28,
        },
        {
          'symbol': 'AMZN',
          'name': 'Amazon.com, Inc.',
          'price': 182.91,
          'changePercentage': -0.44,
        },
        {
          'symbol': 'TSLA',
          'name': 'Tesla, Inc.',
          'price': 171.37,
          'changePercentage': -1.91,
        },
        {
          'symbol': 'META',
          'name': 'Meta Platforms',
          'price': 486.52,
          'changePercentage': 1.17,
        },
        {
          'symbol': 'GOOGL',
          'name': 'Alphabet Inc.',
          'price': 164.43,
          'changePercentage': 0.38,
        },
        {
          'symbol': 'NFLX',
          'name': 'Netflix, Inc.',
          'price': 621.22,
          'changePercentage': 2.03,
        },
        {
          'symbol': 'AMD',
          'name': 'Advanced Micro Devices',
          'price': 162.4,
          'changePercentage': 1.72,
        },
        {
          'symbol': 'UBER',
          'name': 'Uber Technologies',
          'price': 76.18,
          'changePercentage': -0.58,
        },
      ];

  @override
  Future<List<StockModel>> getInitialWatchlist() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    try {
      return _mockResponse
          .take(5)
          .map<StockModel>(StockModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      throw const ServerException('Unable to parse initial market response.');
    }
  }

  @override
  Future<List<StockModel>> getMarketStocks() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    try {
      return _mockResponse
          .map<StockModel>(StockModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      throw const ServerException('Unable to parse market response.');
    }
  }
}
