import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      height: 74,
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
            child: _DayPill(
              day: day,
              date: date,
              tag: tag,
              isActive: isActive,
              isToday: isToday,
              colors: colors,
              onTap: () {
                HapticService.selectionClick();
                provider.setActiveDay(day);
              },
            ),
          );
        },
      ),
    );
  }
}

class _DayPill extends StatefulWidget {
  final String day;
  final DateTime date;
  final String tag;
  final bool isActive;
  final bool isToday;
  final dynamic colors;
  final VoidCallback onTap;

  const _DayPill({
    required this.day,
    required this.date,
    required this.tag,
    required this.isActive,
    required this.isToday,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_DayPill> createState() => _DayPillState();
}

class _DayPillState extends State<_DayPill> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? LinearGradient(
                    colors: [
                      colors.terracotta,
                      Color.lerp(colors.terracotta, colors.ink, 0.35)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? colors.terracotta.withValues(alpha: 0.9)
                  : (widget.isToday
                      ? colors.gold.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.09)),
              width: widget.isActive ? 1.5 : 1.0,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: colors.terracotta.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.day.substring(0, 3).toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: widget.isActive ? Colors.white : colors.cream,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.date.day}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isActive ? Colors.white.withValues(alpha: 0.85) : colors.muted,
                    ),
                  ),
                  if (widget.isToday) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isActive ? Colors.white : colors.gold,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isActive ? Colors.white : colors.gold).withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.tag.isNotEmpty ? widget.tag : ' ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: widget.isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : colors.muted.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
