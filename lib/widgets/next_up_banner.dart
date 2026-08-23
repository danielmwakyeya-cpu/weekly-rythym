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
      duration: const Duration(milliseconds: 1800),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.terracotta.withValues(alpha: 0.15),
              colors.gold.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (info != null ? colors.terracotta : colors.sage).withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing live radar dot
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.35);
                final glowOpacity = 0.25 + (_pulseController.value * 0.4);

                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: info != null ? colors.terracotta : colors.sage,
                    boxShadow: [
                      BoxShadow(
                        color: (info != null ? colors.terracotta : colors.sage).withValues(alpha: glowOpacity),
                        blurRadius: 8 * scale,
                        spreadRadius: 2.5 * scale,
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
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: colors.cream,
                        ),
                        children: [
                          const TextSpan(text: 'Next up: '),
                          TextSpan(
                            text: info.slot.label,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: colors.goldSoft,
                            ),
                          ),
                          TextSpan(
                            text: ' at ${info.timeLabel} • ${info.diffText}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              color: colors.cream.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      'All daily routines wrapped up — enjoy your peaceful flow.',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
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
