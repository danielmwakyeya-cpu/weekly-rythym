import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/default_schedule.dart';
import '../widgets/moon_phase_icon.dart';

class WeekViewScreen extends StatelessWidget {
  const WeekViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final today = provider.todayName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week Overview',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.cream,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.getFormattedScheduleText()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: colors.plum,
                          content: Text('Weekly rhythm copied to clipboard!', style: GoogleFonts.workSans(color: colors.goldSoft)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, size: 18, color: colors.goldSoft),
                    tooltip: 'Copy schedule text',
                  ),
                  IconButton(
                    onPressed: () => provider.resetWeekCompletion(),
                    icon: Icon(Icons.restart_alt, size: 20, color: colors.terracotta),
                    tooltip: 'Reset checkmarks',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7 Day Cards
          ...DefaultSchedule.days.map((dayName) {
            final day = provider.schedule[dayName];
            if (day == null) return const SizedBox.shrink();

            final isToday = dayName == today;
            final pct = day.completionPercent;
            final moonPhase = DefaultSchedule.moonPhaseFor(dayName);

            return GestureDetector(
              onTap: () {
                provider.setActiveDay(dayName);
                provider.setSelectedTab(0); // Switch to Day view
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isToday ? colors.plumLight : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isToday ? colors.terracotta.withOpacity(0.5) : colors.gold.withOpacity(0.15),
                    width: isToday ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Head: Moon + DayName + Fraction
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            MoonPhaseIcon(phase: moonPhase, size: 16, color: colors.goldSoft),
                            const SizedBox(width: 8),
                            Text(
                              dayName,
                              style: GoogleFonts.fraunces(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.cream,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: colors.terracotta,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Today',
                                  style: GoogleFonts.workSans(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${day.doneCount}/${day.totalCount}',
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.goldSoft,
                          ),
                        ),
                      ],
                    ),

                    // Note
                    if (day.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        day.note,
                        style: GoogleFonts.workSans(
                          fontSize: 11.5,
                          color: colors.rose,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: day.totalCount == 0 ? 0.0 : day.completionRatio,
                        minHeight: 4,
                        backgroundColor: colors.plum.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          day.isFullyDone ? colors.sage : colors.terracotta,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mini Slots List
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: day.slots.take(5).map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: s.done ? colors.terracotta.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: s.done ? colors.terracotta.withOpacity(0.4) : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: s.done ? colors.terracotta : colors.muted,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                s.label,
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  color: s.done ? colors.muted : colors.creamDim,
                                  decoration: s.done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
