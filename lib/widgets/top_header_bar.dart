import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import 'doom_timer_dialog.dart';

class TopHeaderBar extends StatelessWidget {
  const TopHeaderBar({super.key});

  void _showEditTitleDialog(BuildContext context, ScheduleProvider provider) {
    final colors = provider.colors;
    final ctrl = TextEditingController(text: provider.appTitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.plum,
        title: Text('Edit App Name', style: GoogleFonts.fraunces(color: colors.cream)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalize the app title to your name or routine.',
              style: GoogleFonts.workSans(color: colors.muted, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: GoogleFonts.workSans(color: colors.cream, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "e.g. Daniel's Rhythm, My Weekly Flow",
                hintStyle: GoogleFonts.workSans(color: colors.muted),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.workSans(color: colors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.terracotta),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.setAppTitle(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
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
              onTap: () => _showEditTitleDialog(context, provider),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      provider.appTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.cream,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 14, color: colors.muted.withOpacity(0.6)),
                ],
              ),
            ),
          ),

          // Focus & Doom Scroll Timer Trigger Button
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => const DoomTimerDialog(),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.timer_outlined,
                size: 20,
                color: colors.goldSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
