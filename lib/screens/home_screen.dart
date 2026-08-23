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

    // Determine slide direction based on old vs new tab
    final slideFromRight = currentTab >= _previousTab;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const TopHeaderBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetIn = slideFromRight
                          ? Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
                          : Tween<Offset>(begin: const Offset(-0.15, 0), end: Offset.zero);

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
              ],
            ),

            // Celebration Confetti Overlay
            const CelebrationOverlay(),

            // Undo Toast Overlay
            const UndoToastWidget(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.plum,
          border: Border(top: BorderSide(color: colors.gold.withOpacity(0.15))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (idx) {
            HapticService.selectionClick();
            _previousTab = currentTab;
            provider.setSelectedTab(idx);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colors.terracotta,
          unselectedItemColor: colors.muted,
          selectedLabelStyle: GoogleFonts.workSans(fontSize: 10.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.workSans(fontSize: 10.5),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 20,
                semanticLabel: 'Today tab'),
              activeIcon: Icon(Icons.calendar_today, size: 20),
              label: 'Today',
              tooltip: 'View today\'s schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_week_outlined, size: 20,
                semanticLabel: 'Week tab'),
              activeIcon: Icon(Icons.view_week, size: 20),
              label: 'Week',
              tooltip: 'View weekly overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sticky_note_2_outlined, size: 20,
                semanticLabel: 'Keep notes tab'),
              activeIcon: Icon(Icons.sticky_note_2, size: 20),
              label: 'Keep',
              tooltip: 'Notes and checklists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined, size: 20,
                semanticLabel: 'Insights tab'),
              activeIcon: Icon(Icons.auto_awesome, size: 20),
              label: 'Insights',
              tooltip: 'View rhythm insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.palette_outlined, size: 20,
                semanticLabel: 'Settings tab'),
              activeIcon: Icon(Icons.palette, size: 20),
              label: 'Settings',
              tooltip: 'App settings and themes',
            ),
          ],
        ),
      ),
    );
  }
}
