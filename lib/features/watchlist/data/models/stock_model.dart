// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../../domain/entities/stock.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 0)
class StockModel extends Stock {
  @HiveField(0)
  @override
  final String symbol;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final double price;

  @HiveField(3)
  @override
  final double changePercentage;

  const StockModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercentage,
  }) : super(
         symbol: symbol,
         name: name,
         price: price,
         changePercentage: changePercentage,
       );

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'changePercentage': changePercentage,
    };
  }

  factory StockModel.fromEntity(Stock stock) {
    return StockModel(
      symbol: stock.symbol,
      name: stock.name,
      price: stock.price,
      changePercentage: stock.changePercentage,
    );
  }
}
