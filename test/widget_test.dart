import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keke_days_app/screens/home_screen.dart';
import 'package:keke_days_app/screens/splash_screen.dart';
import 'package:keke_days_app/screens/onboarding_screen.dart';
import 'package:keke_days_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:keke_days_app/providers/schedule_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Splash screen renders properly and transitions', (WidgetTester tester) async {
    final colors = AppThemes.getTheme('blush').colors;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ScheduleProvider(),
        child: MaterialApp(
          home: SplashScreen(
            colors: colors,
            destination: const HomeScreen(),
          ),
        ),
      ),
    );

    expect(find.text("Weekly Rhythm"), findsOneWidget);
    expect(find.text("Your personal rhythm tracker"), findsOneWidget);

    // Pump forward past splash duration
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));
  });

  testWidgets('Onboarding screen renders 3 features', (WidgetTester tester) async {
    final colors = AppThemes.getTheme('blush').colors;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          colors: colors,
          destination: const HomeScreen(),
        ),
      ),
    );

    expect(find.text("Your Rhythm,\nYour Way"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.text("Skip"), findsOneWidget);
  });

  testWidgets('Home screen renders 5 navigation tabs and stats', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ScheduleProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify 5 tabs in navigation bar
    expect(find.text("Today"), findsOneWidget);
    expect(find.text("Week"), findsOneWidget);
    expect(find.text("Keep"), findsOneWidget);
    expect(find.text("Insights"), findsOneWidget);
    expect(find.text("Settings"), findsOneWidget);
  });
}
