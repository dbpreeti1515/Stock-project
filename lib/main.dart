import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/constants.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'features/watchlist/presentation/pages/watchlist_page.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const StockWatchApp());
}

class StockWatchApp extends StatelessWidget {
  const StockWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.colorScheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.panelStrong,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: BlocProvider<WatchlistBloc>(
        create: (_) => sl<WatchlistBloc>()..add(const LoadWatchlist()),
        child: const WatchlistPage(),
      ),
    );
  }
}
