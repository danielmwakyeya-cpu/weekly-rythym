import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/haptic_service.dart';
import 'doom_timer_dialog.dart';

class TopHeaderBar extends StatelessWidget {
  const TopHeaderBar({super.key});

  void _showEditTitleDialog(BuildContext context, ScheduleProvider provider) {
    final colors = provider.colors;
    final ctrl = TextEditingController(text: provider.appTitle);

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: colors.plum.withValues(alpha: 0.92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Text(
            'Personalize App Name',
            style: GoogleFonts.outfit(
              color: colors.cream,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalize the app title to your name or daily flow.',
                style: GoogleFonts.outfit(color: colors.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: GoogleFonts.outfit(color: colors.cream, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: "e.g. Daniel's Rhythm, My Weekly Flow",
                  hintStyle: GoogleFonts.outfit(color: colors.muted.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.25),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.gold, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.lightTap();
                Navigator.pop(ctx);
              },
              child: Text('Cancel', style: GoogleFonts.outfit(color: colors.muted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: () {
                HapticService.mediumImpact();
                if (ctrl.text.trim().isNotEmpty) {
                  provider.setAppTitle(ctrl.text.trim());
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Title (Tap to Edit)
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticService.lightTap();
                _showEditTitleDialog(context, provider);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.gold.withValues(alpha: 0.25),
                          colors.gold.withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.auto_awesome, size: 14, color: colors.gold),
                  ),
                  Flexible(
                    child: Text(
                      provider.appTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colors.cream,
                        shadows: [
                          Shadow(
                            color: colors.terracotta.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 13, color: colors.muted.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),

          // Focus & Doom Scroll Timer Trigger Button
          _HeaderIconButton(
            icon: Icons.timer_outlined,
            color: colors.goldSoft,
            tooltip: 'Focus & Doom Timer',
            onTap: () {
              HapticService.mediumImpact();
              showDialog(
                context: context,
                builder: (_) => const DoomTimerDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
