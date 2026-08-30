import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Data for a single page of the onboarding carousel.
class OnboardingPageData {
  /// Icon shown at the top (tinted brand circle).
  final IconData icon;

  /// Page headline.
  final String title;

  /// Supporting description.
  final String body;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// Renders one onboarding page: an icon, a title and a description.
///
/// The icon sits inside a soft round canvas and the text is centred beneath,
/// giving each slide the same visual rhythm.
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Icon in a circular brand-tinted disc.
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.indigo, AppColors.cyan],
              ),
            ),
            child: Icon(data.icon, size: 64, color: Colors.white),
          ),
          const Spacer(flex: 1),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}