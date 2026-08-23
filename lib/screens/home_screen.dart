import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/haptic_service.dart';
import '../widgets/top_header_bar.dart';
import '../widgets/undo_toast.dart';
import '../widgets/celebration_overlay.dart';
import 'day_view_screen.dart';
import 'week_view_screen.dart';
import 'keep_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _previousTab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final currentTab = provider.selectedTabIndex.clamp(0, 4);

    final pages = [
      const DayViewScreen(),
      const WeekViewScreen(),
      const KeepScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    final slideFromRight = currentTab >= _previousTab;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const TopHeaderBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetIn = slideFromRight
                          ? Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
                          : Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero);

                      return SlideTransition(
                        position: offsetIn.animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(currentTab),
                      child: pages[currentTab],
                    ),
                  ),
                ),
                // Padding for floating dock
                const SizedBox(height: 80),
              ],
            ),

            // Floating Frosted Glass Bottom Navigation Bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.plum.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: colors.terracotta.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DockNavItem(
                          icon: Icons.calendar_today_outlined,
                          activeIcon: Icons.calendar_today_rounded,
                          label: 'Today',
                          isSelected: currentTab == 0,
                          colors: colors,
                          onTap: () => _switchTab(provider, currentTab, 0),
                        ),
                        _DockNavItem(
                          icon: Icons.view_week_outlined,
                          activeIcon: Icons.view_week_rounded,
                          label: 'Week',
                          isSelected: currentTab == 1,
                          colors: colors,
                          onTap: () => _switchTab(provider, currentTab, 1),
                        ),
                        _DockNavItem(
                          icon: Icons.sticky_note_2_outlined,
                          activeIcon: Icons.sticky_note_2_rounded,
                          label: 'Keep',
                          isSelected: currentTab == 2,
                          colors: colors,
                          onTap: () => _switchTab(provider, currentTab, 2),
                        ),
                        _DockNavItem(
                          icon: Icons.auto_awesome_outlined,
                          activeIcon: Icons.auto_awesome_rounded,
                          label: 'Insights',
                          isSelected: currentTab == 3,
                          colors: colors,
                          onTap: () => _switchTab(provider, currentTab, 3),
                        ),
                        _DockNavItem(
                          icon: Icons.palette_outlined,
                          activeIcon: Icons.palette_rounded,
                          label: 'Settings',
                          isSelected: currentTab == 4,
                          colors: colors,
                          onTap: () => _switchTab(provider, currentTab, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Celebration Confetti Overlay
            const CelebrationOverlay(),

            // Undo Toast Overlay
            const UndoToastWidget(),
          ],
        ),
      ),
    );
  }

  void _switchTab(ScheduleProvider provider, int currentTab, int targetTab) {
    if (currentTab == targetTab) return;
    HapticService.selectionClick();
    setState(() {
      _previousTab = currentTab;
    });
    provider.setSelectedTab(targetTab);
  }
}

class _DockNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final dynamic colors;
  final VoidCallback onTap;

  const _DockNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.terracotta.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.terracotta.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? colors.goldSoft : colors.muted,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: colors.gold.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.cream : colors.muted.withValues(alpha: 0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
