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
      backgroundColor: colors.plum,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duplicate ${provider.activeDay} to...',
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.cream,
              ),
            ),
            const SizedBox(height: 12),
            ...otherDays.map((d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d, style: GoogleFonts.workSans(color: colors.cream, fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: colors.gold),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.duplicateDay(provider.activeDay, d);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _swipeDay(ScheduleProvider provider, int direction) {
    final days = DefaultSchedule.days;
    final currentIdx = days.indexOf(provider.activeDay);
    final newIdx = (currentIdx + direction).clamp(0, days.length - 1);
    if (newIdx != currentIdx) {
      HapticService.selectionClick();
      provider.setActiveDay(days[newIdx]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    // Show shimmer while loading
    if (provider.isLoading) {
      return ShimmerDayView(
        baseColor: colors.plum.withOpacity(0.5),
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
          _swipeDay(provider, 1); // Swipe left → next day
        } else if (details.primaryVelocity! > 200) {
          _swipeDay(provider, -1); // Swipe right → prev day
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
        children: [
          // Weekly Statistics Bar
          const StatsBar(),

          // Countdown to Next Task
          const NextUpBanner(),

          // Day Selector Tabs (Mon - Sun)
          const DaySelectorBar(),
          const SizedBox(height: 8),

          // Main Daily Rhythm Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.plumLight,
                  colors.plum,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.gold.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Shimmer stripe
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

                // Header Row: Day Title + Moon Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          day.dayName,
                          style: GoogleFonts.fraunces(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: colors.cream,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MoonPhaseIcon(phase: moonPhase, size: 20, color: colors.goldSoft),
                      ],
                    ),

                    // Done count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.terracotta.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.terracotta.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${day.doneCount}/${day.totalCount} done',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.goldSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons: Duplicate & Reset Day
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDuplicateDialog(context, provider),
                        icon: Icon(Icons.copy_outlined, size: 14, color: colors.muted),
                        label: Text('Duplicate', style: GoogleFonts.workSans(fontSize: 11.5, color: colors.muted)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.resetDayToDefault(provider.activeDay),
                        icon: Icon(Icons.refresh, size: 14, color: colors.muted),
                        label: Text('Reset day', style: GoogleFonts.workSans(fontSize: 11.5, color: colors.muted)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Day Note (Editable)
                TextField(
                  controller: _dayNoteCtrl,
                  style: GoogleFonts.workSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: colors.rose,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note for ${day.dayName}...',
                    hintStyle: GoogleFonts.workSans(color: colors.rose.withOpacity(0.5)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Text(
                            "Today's energy:",
                            style: GoogleFonts.workSans(fontSize: 11, color: colors.muted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          _moodButton('low', '\u{1F634}', 'Low', provider, colors),
                          const SizedBox(width: 5),
                          _moodButton('medium', '\u{1F642}', 'Med', provider, colors),
                          const SizedBox(width: 5),
                          _moodButton('high', '\u26A1', 'High', provider, colors),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // General Today Journal Box
                  TextField(
                    controller: _journalCtrl,
                    maxLines: 2,
                    style: GoogleFonts.workSans(fontSize: 12.5, color: colors.cream),
                    decoration: InputDecoration(
                      hintText: 'Jot a quick note about today...',
                      hintStyle: GoogleFonts.workSans(fontSize: 12, color: colors.muted.withOpacity(0.6)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    onChanged: (val) => provider.setTodayJournalNote(val),
                  ),
                  const SizedBox(height: 16),
                ],

                // Reorderable Slots List
                if (day.slots.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Icon(Icons.event_note_outlined, size: 48, color: colors.muted.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'Nothing planned for ${day.dayName} yet',
                            style: GoogleFonts.fraunces(fontSize: 15, color: colors.cream),
                          ),
                          Text(
                            'Tap "+ Add a task" below or choose a template',
                            style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
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
                        slot: slot,
                        isCurrent: isToday && i == currentSlotIdx,
                        onEdit: () => _showEditSlotDialog(context, provider, i, slot),
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
                      style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600, color: colors.goldSoft),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.gold.withOpacity(0.35), style: BorderStyle.solid),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: colors.gold.withOpacity(0.06),
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
      onTap: () => provider.setTodayMood(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colors.terracotta.withOpacity(0.3) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? colors.terracotta : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 10.5,
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
