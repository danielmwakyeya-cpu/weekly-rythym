import 'dart:math';
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
      duration: const Duration(seconds: 24),
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
        // Base dark ink background
        Container(
          color: colors.ink,
        ),

        // Ambient drifting warm radial glow 1
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final val = _controller.value;
            final offsetX = sin(val * 2 * pi) * 40;
            final offsetY = cos(val * 2 * pi) * 30;

            return Positioned(
              top: -80 + offsetY,
              left: -80 + offsetX,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.gold.withOpacity(0.14),
                      colors.gold.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Ambient drifting terracotta glow 2
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final val = _controller.value;
            final offsetX = cos(val * 2 * pi) * 40;
            final offsetY = sin(val * 2 * pi) * 40;

            return Positioned(
              bottom: -60 + offsetY,
              right: -60 + offsetX,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.terracotta.withOpacity(0.13),
                      colors.terracotta.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}
