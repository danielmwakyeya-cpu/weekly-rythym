import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    final pct = provider.weekCompletionPct;
    final done = provider.doneTasksThisWeek;
    final total = provider.totalTasksThisWeek;
    final fullDays = provider.fullDaysThisWeek;
    final streak = provider.dayStreak;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 1. Ring Chart Card
          _StatsCard(
            colors: colors,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  height: 46,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: pct / 100.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) => CustomPaint(
                      painter: _RingProgressPainter(
                        progress: val,
                        trackColor: colors.plumLight.withValues(alpha: 0.45),
                        gradientColors: [colors.gold, colors.terracotta],
                      ),
                      child: Center(
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: colors.goldSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$done / $total',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: colors.goldSoft,
                      ),
                    ),
                    Text(
                      'Tasks done this week',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.muted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 2. Full Days Complete
          _StatsCard(
            colors: colors,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$fullDays / 7',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colors.goldSoft,
                  ),
                ),
                Text(
                  'Fully complete days',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.muted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 3. Day Streak
          _StatsCard(
            colors: colors,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: colors.goldSoft,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '🔥',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  'Day streak',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.muted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final dynamic colors;
  final Widget child;

  const _StatsCard({
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.015),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> gradientColors;

  _RingProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
