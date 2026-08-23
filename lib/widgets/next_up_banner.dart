import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class NextUpBanner extends StatefulWidget {
  const NextUpBanner({super.key});

  @override
  State<NextUpBanner> createState() => _NextUpBannerState();
}

class _NextUpBannerState extends State<NextUpBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final info = provider.nextUpInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.terracotta.withOpacity(0.18),
              colors.gold.withOpacity(0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.terracotta.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            // Pulsing dot
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.3);
                final glowOpacity = 0.25 + (_pulseController.value * 0.2);

                return Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: info != null ? colors.terracotta : colors.sage,
                    boxShadow: [
                      BoxShadow(
                        color: (info != null ? colors.terracotta : colors.sage).withOpacity(glowOpacity),
                        blurRadius: 6 * scale,
                        spreadRadius: 2 * scale,
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Banner text
            Expanded(
              child: info != null
                  ? RichText(
                      text: TextSpan(
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: colors.cream,
                        ),
                        children: [
                          const TextSpan(text: 'Next up '),
                          TextSpan(
                            text: info.slot.label,
                            style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w700,
                              color: colors.goldSoft,
                            ),
                          ),
                          TextSpan(text: ' at ${info.timeLabel} (${info.diffText})'),
                        ],
                      ),
                    )
                  : Text(
                      'Nothing else timed for today â€” enjoy the rest of it.',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: colors.creamDim,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
