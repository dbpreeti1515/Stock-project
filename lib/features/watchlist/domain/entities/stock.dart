import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  const Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercentage,
  });

  final String symbol;
  final String name;
  final double price;
  final double changePercentage;

  bool get isPositive => changePercentage >= 0;

  Stock copyWith({
    String? symbol,
    String? name,
    double? price,
    double? changePercentage,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      changePercentage: changePercentage ?? this.changePercentage,
    );
  }

  @override
  List<Object> get props => [symbol, name, price, changePercentage];
}
