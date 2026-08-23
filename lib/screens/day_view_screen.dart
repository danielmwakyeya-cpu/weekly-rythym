import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../services/default_schedule.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../widgets/moon_phase_icon.dart';
import '../widgets/slot_card_widget.dart';
import '../widgets/slot_edit_dialog.dart';
import '../widgets/quick_templates.dart';
import '../widgets/stats_bar.dart';
import '../widgets/next_up_banner.dart';
import '../widgets/day_selector_bar.dart';
import '../widgets/shimmer_loading.dart';

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  late TextEditingController _dayNoteCtrl;
  late TextEditingController _journalCtrl;

  @override
  void initState() {
    super.initState();
    _dayNoteCtrl = TextEditingController();
    _journalCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _dayNoteCtrl.dispose();
    _journalCtrl.dispose();
    super.dispose();
  }

  void _showAddSlotDialog(BuildContext context, ScheduleProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => SlotEditDialog(
        colors: provider.colors,
        onSave: (newSlot) => provider.addSlot(provider.activeDay, newSlot),
      ),
    );
  }

  void _showEditSlotDialog(BuildContext context, ScheduleProvider provider, int index, SlotModel slot) {
    showDialog(
      context: context,
      builder: (ctx) => SlotEditDialog(
        colors: provider.colors,
        slot: slot,
        onSave: (updated) => provider.updateSlot(provider.activeDay, index, updated),
        onDelete: () => provider.deleteSlot(provider.activeDay, index),
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context, ScheduleProvider provider) {
    final colors = provider.colors;
    final otherDays = DefaultSchedule.days.where((d) => d != provider.activeDay).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.plum.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Copy ${provider.activeDay}\'s Rhythm to...',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a day to duplicate all routines and notes to:',
                style: GoogleFonts.outfit(color: colors.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: otherDays.map((d) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.terracotta.withValues(alpha: 0.2),
                      foregroundColor: colors.cream,
                      side: BorderSide(color: colors.terracotta.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      HapticService.mediumImpact();
                      provider.duplicateDay(provider.activeDay, d);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied ${provider.activeDay} to $d!')),
                      );
                    },
                    child: Text(d, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _swipeDay(ScheduleProvider provider, int direction) {
    final days = DefaultSchedule.days;
    final currentIdx = days.indexOf(provider.activeDay);
    if (currentIdx == -1) return;
    final newIdx = (currentIdx + direction) % days.length;
    final targetIdx = newIdx < 0 ? days.length - 1 : newIdx;
    HapticService.selectionClick();
    provider.setActiveDay(days[targetIdx]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    if (provider.isLoading) {
      return ShimmerDayView(
        baseColor: colors.plum.withValues(alpha: 0.5),
        highlightColor: colors.plumLight,
      );
    }

    final day = provider.schedule[provider.activeDay];
    if (day == null) return const SizedBox.shrink();

    final isToday = provider.activeDay == provider.todayName;
    final moonPhase = DefaultSchedule.moonPhaseFor(provider.activeDay);

    if (_dayNoteCtrl.text != day.note) {
      _dayNoteCtrl.text = day.note;
    }

    final todayJournal = provider.getTodayJournalNote();
    if (_journalCtrl.text != todayJournal) {
      _journalCtrl.text = todayJournal;
    }

    final currentSlotIdx = provider.currentSlotIndex;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          _swipeDay(provider, 1);
        } else if (details.primaryVelocity! > 200) {
          _swipeDay(provider, -1);
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const StatsBar(),
            const NextUpBanner(),
            const DaySelectorBar(),
            const SizedBox(height: 8),

            // Main Daily Rhythm Glass Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.plumLight.withValues(alpha: 0.85),
                    colors.plum.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer accent line
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.gold, colors.terracotta, colors.sage, colors.gold],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row: Day Title + Moon Icon + Done badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            day.dayName,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: colors.cream,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MoonPhaseIcon(phase: moonPhase, size: 20, color: colors.goldSoft),
                        ],
                      ),

                      // Completion badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.terracotta.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.terracotta.withValues(alpha: 0.45)),
                        ),
                        child: Text(
                          '${day.doneCount}/${day.totalCount} done',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.goldSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons: Duplicate & Reset
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDuplicateDialog(context, provider),
                          icon: Icon(Icons.copy_outlined, size: 14, color: colors.muted),
                          label: Text('Duplicate', style: GoogleFonts.outfit(fontSize: 12, color: colors.muted, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticService.selectionClick();
                            provider.resetDayToDefault(provider.activeDay);
                          },
                          icon: Icon(Icons.refresh, size: 14, color: colors.muted),
                          label: Text('Reset day', style: GoogleFonts.outfit(fontSize: 12, color: colors.muted, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Day Note
                  TextField(
                    controller: _dayNoteCtrl,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.rose,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a focus theme for ${day.dayName}...',
                      hintStyle: GoogleFonts.outfit(color: colors.rose.withValues(alpha: 0.45)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => provider.setDayNote(provider.activeDay, val),
                  ),
                  const SizedBox(height: 14),

                  // Energy / Mood Tag (Today only)
                  if (isToday) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            Text(
                              "Today's Energy:",
                              style: GoogleFonts.outfit(fontSize: 12, color: colors.muted, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 10),
                            _moodButton('low', '😴', 'Low', provider, colors),
                            const SizedBox(width: 6),
                            _moodButton('medium', '🙂', 'Med', provider, colors),
                            const SizedBox(width: 6),
                            _moodButton('high', '⚡', 'High', provider, colors),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Reflection Box
                    TextField(
                      controller: _journalCtrl,
                      maxLines: 2,
                      style: GoogleFonts.outfit(fontSize: 13, color: colors.cream),
                      decoration: InputDecoration(
                        hintText: 'Jot a quick thought or win for today...',
                        hintStyle: GoogleFonts.outfit(fontSize: 12.5, color: colors.muted.withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.gold.withValues(alpha: 0.5)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (val) => provider.setTodayJournalNote(val),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reorderable Slots List
                  if (day.slots.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.event_note_outlined, size: 48, color: colors.muted.withValues(alpha: 0.4)),
                            const SizedBox(height: 10),
                            Text(
                              'Nothing planned for ${day.dayName} yet',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.cream),
                            ),
                            Text(
                              'Tap "+ Add a task" below or choose a template',
                              style: GoogleFonts.outfit(fontSize: 13, color: colors.muted),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: day.slots.length,
                      onReorder: (oldIdx, newIdx) => provider.reorderSlots(provider.activeDay, oldIdx, newIdx),
                      itemBuilder: (context, i) {
                        final slot = day.slots[i];
                        return SlotCardWidget(
                          key: ValueKey('${day.dayName}_${slot.label}_$i'),
                          day: day.dayName,
                          index: i,
                          isCurrent: isToday && i == currentSlotIdx,
                          onEdit: () => _showEditSlotDialog(context, provider, i, slot),
                          onDelete: () => provider.deleteSlot(provider.activeDay, i),
                        );
                      },
                    ),
                  const SizedBox(height: 16),

                  // Add Task Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddSlotDialog(context, provider),
                      icon: Icon(Icons.add, size: 18, color: colors.goldSoft),
                      label: Text(
                        '+ Add a task',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: colors.goldSoft),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gold.withValues(alpha: 0.35)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colors.gold.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quick Templates Bar
                  QuickTemplatesBar(
                    colors: colors,
                    onAddTemplate: (tpl) => provider.addSlot(provider.activeDay, tpl),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodButton(String level, String emoji, String label, ScheduleProvider provider, AppColors colors) {
    final selected = provider.currentMood == level;
    return GestureDetector(
      onTap: () {
        HapticService.selectionClick();
        provider.setTodayMood(level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? colors.terracotta.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.terracotta : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.terracotta.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.goldSoft : colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
