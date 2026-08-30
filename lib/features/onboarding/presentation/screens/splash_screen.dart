import 'package:flutter/material.dart';

import '../../../../app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/scans/presentation/screens/home_screen.dart';
import 'onboarding_screen.dart';

/// Branded splash screen shown briefly at startup.
///
/// Displays the logo + app name for a moment (letting the native splash
/// transition smoothly into the Flutter UI), then routes the user either to
/// the onboarding flow (first launch) or straight to the home screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// How long the splash is shown before navigating.
  static const Duration _splashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _scheduleNavigation();
  }

  /// Waits, then decides the first destination and replaces this screen.
  Future<void> _scheduleNavigation() async {
    await Future<void>.delayed(_splashDuration);
    if (!mounted) return;

    // Resolve the store outside build so no dependency is registered.
    final AppScope scope = AppScope.read(context);

    // First run -> onboarding; otherwise go straight home.
    final bool firstRun = !await scope.onboardingStore.hasCompleted;
    if (!mounted) return;

    final Widget destination = firstRun
        ? const OnboardingScreen()
        : const HomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A full-bleed brand gradient that matches the native splash.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.indigo, AppColors.cyan],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Echo the launcher icon glyph inside a frosted-white circle.
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.document_scanner_outlined,
                  size: 56,
                  color: AppColors.indigo,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Capture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Offline text recognition',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}