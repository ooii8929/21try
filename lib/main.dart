import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';
import 'services/isar_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Isar
  await IsarService.initialize();

  runApp(const TwentyOneTryApp());
}

class TwentyOneTryApp extends StatelessWidget {
  const TwentyOneTryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '21 Try',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Manrope',
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
      ),
      navigatorObservers: [routeObserver],
      home: const HomeScreen(),
    );
  }
}
