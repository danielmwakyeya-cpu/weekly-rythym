import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/haptic_service.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    HapticService.heavyImpact();
    _confettiController.play();
    _bounceController.forward(from: 0.0);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<ScheduleProvider>().dismissCelebration();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final showCelebration = provider.showCelebration;

    if (showCelebration) {
      // Trigger on next frame to avoid build-time setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _confettiController.state != ConfettiControllerState.playing) {
          _triggerCelebration();
        }
      });
    }

    if (!showCelebration && _confettiController.state != ConfettiControllerState.playing) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti from top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 60,
              minBlastForce: 20,
              emissionFrequency: 0.06,
              gravity: 0.15,
              colors: [
                colors.terracotta,
                colors.gold,
                colors.sage,
                colors.rose,
                Colors.white,
                colors.goldSoft,
              ],
            ),
          ),

          // "All Done!" banner
          if (showCelebration)
            Center(
              child: ScaleTransition(
                scale: _bounceAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.terracotta.withOpacity(0.95),
                        colors.gold.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.terracotta.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        'All Done!',
                        style: GoogleFonts.fraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You've completed every task today!",
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
