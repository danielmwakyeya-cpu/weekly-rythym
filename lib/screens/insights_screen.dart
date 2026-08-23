import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/default_schedule.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    final weekHistory = provider.weekHistory;
    final dayHistory = provider.schedule;

    String? toughestDay;
    String? strongestDay;
    double minRatio = 1.1;
    double maxRatio = -0.1;

    for (final dayName in DefaultSchedule.days) {
      final d = dayHistory[dayName];
      if (d == null || d.totalCount == 0) continue;
      if (d.completionRatio < minRatio) {
        minRatio = d.completionRatio;
        toughestDay = dayName;
      }
      if (d.completionRatio > maxRatio) {
        maxRatio = d.completionRatio;
        strongestDay = dayName;
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rhythm Insights',
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Patterns and trends across your weekly routines.',
            style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
          ),
          const SizedBox(height: 16),

          // 0. Streak & Badges Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.gold.withOpacity(0.15),
                  colors.terracotta.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.gold.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      provider.dayStreak > 0 ? '\u{1F525}' : '\u{1F3AF}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streaks & Achievements',
                            style: GoogleFonts.fraunces(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.cream,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Complete all daily tasks to build your streak!',
                            style: GoogleFonts.workSans(fontSize: 11, color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _streakStat('Current', '${provider.dayStreak}', '\u{1F525}', colors),
                    const SizedBox(width: 10),
                    _streakStat('Longest', '${provider.longestStreak}', '\u{1F3C6}', colors),
                    const SizedBox(width: 10),
                    _streakStat('Full Days', '${provider.fullDaysThisWeek}/7', '\u{2B50}', colors),
                  ],
                ),
                if (provider.earnedBadges.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Earned Badges',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: provider.earnedBadges.map((badge) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.terracotta.withOpacity(0.3), colors.gold.withOpacity(0.2)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.gold.withOpacity(0.4)),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.goldSoft,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Day Pattern Highlight Card
          if (toughestDay != null && strongestDay != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.terracotta.withOpacity(0.2),
                    colors.gold.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.terracotta.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u{1F4CA}', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Rhythm Analysis',
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.goldSoft,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.workSans(fontSize: 13, color: colors.cream),
                            children: [
                              TextSpan(text: '$strongestDay', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' is currently your strongest day ('),
                              TextSpan(
                                text: '${(maxRatio * 100).round()}% done',
                                style: TextStyle(color: colors.sage, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '). '),
                              TextSpan(text: '$toughestDay', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' tends to have the most unfinished items. Consider lightening its load!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 2. Past Weeks Completion History
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.gold.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Past Weeks Trend',
                  style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: colors.cream),
                ),
                const SizedBox(height: 12),
                if (weekHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No archived weeks yet. Your weekly trends will automatically record at each rollover!',
                      style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
                    ),
                  )
                else
                  ...weekHistory.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Week of ${item.weekOf}',
                              style: GoogleFonts.workSans(fontSize: 12, color: colors.creamDim),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: item.percent / 100.0,
                                minHeight: 6,
                                backgroundColor: colors.plumLight,
                                valueColor: AlwaysStoppedAnimation<Color>(colors.terracotta),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${item.percent}%',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.goldSoft,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Adaptive Tip Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.gold.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Text('\u{1F4A1}', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rhythm Protection Tip',
                        style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: colors.cream),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule guilt-free decompression buffer blocks before intensive shifts and study sessions.',
                        style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakStat(String label, String value, String emoji, dynamic colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.goldSoft,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.workSans(fontSize: 10, color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
