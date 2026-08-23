import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class OnboardingScreen extends StatefulWidget {
  final AppColors colors;
  final Widget destination;

  const OnboardingScreen({
    super.key,
    required this.colors,
    required this.destination,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.calendar_month_rounded,
      secondaryIcon: Icons.wb_sunny_rounded,
      title: 'Your Rhythm,\nYour Way',
      subtitle:
          'Plan your week with flexible daily routines. Drag, reorder, and customize every time slot to match your unique flow.',
      gradient: [Color(0xFFE8A4BD), Color(0xFFD4A574)],
    ),
    _OnboardingPage(
      icon: Icons.sticky_note_2_rounded,
      secondaryIcon: Icons.link_rounded,
      title: 'Smart Notes\n& Linking',
      subtitle:
          'Google Keep-style notes that intelligently connect to your tasks. Tag, pin, and checklist everything — auto-linked to your daily activities.',
      gradient: [Color(0xFFD4A574), Color(0xFFA8B5A2)],
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      secondaryIcon: Icons.local_fire_department_rounded,
      title: 'Stay Ahead\nAlways',
      subtitle:
          'Smart multi-tier reminders (1 month, 2 weeks, 1 week, 1 day), streak tracking, focus timer, and beautiful insights to keep you going.',
      gradient: [Color(0xFFA8B5A2), Color(0xFFB8A9C9)],
    ),
  ];

  void _next() {
    HapticService.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    HapticService.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.destination,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Scaffold(
      backgroundColor: colors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.workSans(
                      color: colors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon cluster
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: page.gradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: page.gradient[0].withOpacity(0.3),
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(page.icon, size: 60, color: Colors.white.withOpacity(0.9)),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.3),
                                    border: Border.all(color: Colors.white24, width: 2),
                                  ),
                                  child: Icon(
                                    page.secondaryIcon,
                                    size: 22,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: colors.cream,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            color: colors.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == i
                              ? colors.terracotta
                              : colors.muted.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == _pages.length - 1 ? 28 : 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.terracotta, colors.gold],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.terracotta.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final IconData secondaryIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  _OnboardingPage({
    required this.icon,
    required this.secondaryIcon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
