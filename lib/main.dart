import 'package:admin_market/auth/login.dart';
import 'package:admin_market/bloc/banner_cubit.dart';
import 'package:admin_market/bloc/order_cubit.dart';
import 'package:admin_market/bloc/product_cubit.dart';
import 'package:admin_market/bloc/voucher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductCubit({})),
        BlocProvider(create: (context) => OrderCubit({})),
        BlocProvider(create: (context) => VoucherCubit({})),
        BlocProvider(create: (context) => BannerCubit({})),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color.fromARGB(255, 0, 172, 254)),
          useMaterial3: true),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color.fromARGB(255, 13, 3, 118)),
          useMaterial3: true),
        home: const Login(),
      ),
    );
  }
}
