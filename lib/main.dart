import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/schedule_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize notifications
  await NotificationService.init();
  await NotificationService.requestPermissions();

  runApp(const KekeRhythmApp());
}

class KekeRhythmApp extends StatelessWidget {
  const KekeRhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          final colors = provider.colors;

          return MaterialApp(
            title: "Weekly Rhythm",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: colors.ink,
              primaryColor: colors.terracotta,
              colorScheme: ColorScheme.dark(
                primary: colors.terracotta,
                secondary: colors.gold,
                surface: colors.plum,
              ),
              textTheme: GoogleFonts.workSansTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
              useMaterial3: true,
            ),
            home: _AppLauncher(colors: colors, provider: provider),
          );
        },
      ),
    );
  }
}

/// Handles the launch flow: Splash → (Onboarding) → (Lock) → Home
class _AppLauncher extends StatefulWidget {
  final AppColors colors;
  final ScheduleProvider provider;

  const _AppLauncher({required this.colors, required this.provider});

  @override
  State<_AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<_AppLauncher> {
  bool _ready = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingDone;
        _ready = true;
      });
    }
  }

  Widget _buildDestination() {
    if (widget.provider.biometricLockEnabled) {
      return LockScreen(
        colors: widget.colors,
        destination: const HomeScreen(),
      );
    }
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(backgroundColor: widget.colors.ink);
    }

    final destination = _showOnboarding
        ? OnboardingScreen(
            colors: widget.colors,
            destination: _buildDestination(),
          )
        : _buildDestination();

    return SplashScreen(
      colors: widget.colors,
      destination: destination,
    );
  }
}
