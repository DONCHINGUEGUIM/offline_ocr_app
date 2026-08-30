import 'package:flutter/material.dart';

import '../../../../app_scope.dart';
import '../../../../features/scans/presentation/screens/home_screen.dart';
import '../widgets/onboarding_page.dart';

/// First-run onboarding carousel.
///
/// Swipeable through a few short slides, with Skip / Next / Get Started
/// controls and a page indicator. Reaching the end (or tapping Skip) marks
/// onboarding as complete and routes to the home screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// The current page index shown in the carousel.
  int _currentPage = 0;

  /// Controller backing the swipeable [PageView].
  final PageController _pageController = PageController();

  /// The three onboarding slides.
  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.document_scanner_outlined,
      title: 'Scan any document',
      body:
          'Take a photo or pick any image and Capture will turn the text in '
          'it into editable, copyable text in seconds.',
    ),
    OnboardingPageData(
      icon: Icons.cloud_off_outlined,
      title: 'Works fully offline',
      body:
          'Your images never leave your device. All recognition happens '
          'on-device, so you can scan anywhere — no internet needed.',
    ),
    OnboardingPageData(
      icon: Icons.folder_copy_outlined,
      title: 'Your scans, organised',
      body:
          'Every extraction is saved to your scan history, ready to copy '
          'again or delete whenever you like.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// True when showing the last slide (enables "Get Started").
  bool get _isLastPage => _currentPage == _pages.length - 1;

  /// Advances to the next page, or finishes onboarding on the last one.
  void _nextPage() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Marks onboarding complete and routes home.
  Future<void> _finish() async {
    await AppScope.read(context).onboardingStore.complete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _isLastPage;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top-right) only on non-final pages.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isLast
                          ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                          : scheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (_, int index) => OnboardingPage(data: _pages[index]),
              ),
            ),
            // Dot indicator.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (int i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _nextPage,
                child: Text(isLast ? 'Get Started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}