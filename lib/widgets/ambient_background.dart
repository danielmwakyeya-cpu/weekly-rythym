import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/schedule_provider.dart';
import 'package:provider/provider.dart';

class AmbientBackground extends StatefulWidget {
  final Widget child;
  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ScheduleProvider>().colors;

    return Stack(
      children: [
        // Base dark luxury background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.ink,
                Color.lerp(colors.ink, Colors.black, 0.4)!,
              ],
            ),
          ),
        ),

        // Ambient Orb 1: Primary Gold / Accent glow (top-left floating)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final val = _controller.value;
            final offsetX = sin(val * 2 * pi) * 60;
            final offsetY = cos(val * 2 * pi) * 45;
            final scale = 1.0 + sin(val * pi) * 0.15;

            return Positioned(
              top: -60 + offsetY,
              left: -60 + offsetX,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.gold.withValues(alpha: 0.18),
                        colors.gold.withValues(alpha: 0.06),
                        colors.gold.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Ambient Orb 2: Terracotta / Rose glow (bottom-right floating)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final val = _controller.value;
            final offsetX = cos(val * 2 * pi) * 55;
            final offsetY = sin(val * 2 * pi) * 50;
            final scale = 1.0 + cos(val * pi) * 0.12;

            return Positioned(
              bottom: -80 + offsetY,
              right: -80 + offsetX,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.terracotta.withValues(alpha: 0.16),
                        colors.terracotta.withValues(alpha: 0.05),
                        colors.terracotta.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Ambient Orb 3: Sage / Indigo mid-screen atmospheric depth
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final val = _controller.value;
            final offsetX = sin((val + 0.5) * 2 * pi) * 40;
            final offsetY = cos((val + 0.5) * 2 * pi) * 60;

            return Positioned(
              top: MediaQuery.of(context).size.height * 0.35 + offsetY,
              left: MediaQuery.of(context).size.width * 0.2 + offsetX,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.sage.withValues(alpha: 0.08),
                      colors.sage.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Subtle noise/frost overlay blur for soft cinematic diffusion
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: const SizedBox.expand(),
        ),

        // Foreground Content
        widget.child,
      ],
    );
  }
}
