import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/default_schedule.dart';
import '../services/haptic_service.dart';

class DaySelectorBar extends StatelessWidget {
  const DaySelectorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final activeDay = provider.activeDay;
    final today = provider.todayName;

    // Compute dates for Monday..Sunday of current week
    final now = DateTime.now();
    final mondayOffset = now.weekday - 1;
    final monday = now.subtract(Duration(days: mondayOffset));

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: DefaultSchedule.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = DefaultSchedule.days[i];
          final isActive = day == activeDay;
          final isToday = day == today;
          final date = monday.add(Duration(days: i));
          final tag = DefaultSchedule.tagFor(day);

          return Semantics(
            label: '$day ${isToday ? "today" : ""} ${isActive ? "selected" : ""}',
            button: true,
            child: GestureDetector(
            onTap: () {
              HapticService.selectionClick();
              provider.setActiveDay(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          colors.terracotta,
                          Color.lerp(colors.terracotta, Colors.black, 0.3)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? colors.terracotta : colors.gold.withOpacity(0.2),
                  width: isActive ? 1.5 : 1.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: colors.terracotta.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day.substring(0, 3),
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : colors.cream,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${date.day}',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.white.withOpacity(0.8) : colors.muted,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.white : colors.gold,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tag.isNotEmpty ? tag : ' ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.workSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white.withOpacity(0.85) : colors.muted.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}
