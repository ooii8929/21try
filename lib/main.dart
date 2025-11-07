import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
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

  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(TwentyOneTryApp(showOnboarding: !hasSeenOnboarding));
}

class TwentyOneTryApp extends StatelessWidget {
  final bool showOnboarding;

  const TwentyOneTryApp({Key? key, required this.showOnboarding})
      : super(key: key);

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
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
