import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../models/keep_note_model.dart';
import '../providers/schedule_provider.dart';
import '../services/haptic_service.dart';

class SlotCardWidget extends StatefulWidget {
  final String day;
  final int index;
  final SlotModel slot;
  final bool isCurrent;
  final VoidCallback onEdit;

  const SlotCardWidget({
    super.key,
    required this.day,
    required this.index,
    required this.slot,
    required this.isCurrent,
    required this.onEdit,
  });

  @override
  State<SlotCardWidget> createState() => _SlotCardWidgetState();
}

class _SlotCardWidgetState extends State<SlotCardWidget> {
  bool _showJournalNote = false;
  bool _showLinkedNotes = false;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final slot = widget.slot;
    final isToday = widget.day == provider.todayName;
    final existingNote = isToday ? provider.getTaskJournalNote(slot.label) : '';

    if (_noteController.text != existingNote && !_showJournalNote) {
      _noteController.text = existingNote;
    }

    final double progress = widget.isCurrent ? provider.getSlotProgress(widget.index) : 0.0;
    final linkedNotes = provider.getLinkedNotesForSlot(slot, widget.day);

    return Dismissible(
      key: ValueKey('dismiss_${widget.day}_${slot.label}_${widget.index}'),
      direction: slot.done ? DismissDirection.none : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        HapticService.mediumImpact();
        provider.toggleSlotDone(widget.day, widget.index);
        return false; // Don't remove the widget, just toggle done
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.sage.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: colors.sage, size: 24),
            const SizedBox(width: 8),
            Text('Done!', style: TextStyle(color: colors.sage, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: Semantics(
        label: '${slot.label}, ${slot.done ? "completed" : "pending"}, ${slot.time}',
        child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isCurrent
            ? colors.terracotta.withOpacity(0.1)
            : (slot.done ? Colors.black.withOpacity(0.12) : Colors.white.withOpacity(0.025)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCurrent
              ? colors.terracotta.withOpacity(0.45)
              : (slot.done ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle icon
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.drag_indicator,
                      color: colors.muted.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ),

                // Custom Checkbox
                GestureDetector(
                  onTap: () => provider.toggleSlotDone(widget.day, widget.index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: slot.done ? colors.terracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: slot.done ? colors.terracotta : colors.gold.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: slot.done
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Slot Info
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onEdit,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time + Pills + Now badge
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              slot.time,
                              style: GoogleFonts.workSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: colors.goldSoft,
                              ),
                            ),
                            if (widget.isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: colors.terracotta,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Now',
                                  style: GoogleFonts.workSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (slot.kind != SlotKind.normal)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: slot.kind == SlotKind.fixed
                                      ? colors.sage.withOpacity(0.2)
                                      : colors.terracotta.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  slot.kind.displayName,
                                  style: GoogleFonts.workSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: slot.kind == SlotKind.fixed ? colors.sage : colors.terracotta,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Label
                        Text(
                          slot.label,
                          style: GoogleFonts.fraunces(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: slot.done ? colors.muted : colors.cream,
                            decoration: slot.done ? TextDecoration.lineThrough : null,
                          ),
                        ),

                        // Description
                        if (slot.desc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            slot.desc,
                            style: GoogleFonts.workSans(
                              fontSize: 11.5,
                              color: colors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Journal icon (Today only)
                if (isToday)
                  IconButton(
                    icon: Icon(
                      existingNote.isNotEmpty ? Icons.note_alt : Icons.note_alt_outlined,
                      size: 16,
                      color: existingNote.isNotEmpty ? colors.gold : colors.muted.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() => _showJournalNote = !_showJournalNote);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),

                // Edit Button
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 16, color: colors.muted.withOpacity(0.6)),
                  onPressed: widget.onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),

          // --- SMART LINKING CONTEXT LAYER ---
          if (linkedNotes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showLinkedNotes = !_showLinkedNotes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.sage.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.sage.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sticky_note_2_outlined, size: 12, color: colors.sage),
                          const SizedBox(width: 4),
                          Text(
                            '${linkedNotes.length} Linked Keep Note${linkedNotes.length > 1 ? "s" : ""}',
                            style: GoogleFonts.workSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: colors.sage),
                          ),
                          const SizedBox(width: 4),
                          Icon(_showLinkedNotes ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: colors.sage),
                        ],
                      ),
                    ),
                  ),

                  // Expandable Live Checklist / Note Content directly on card
                  if (_showLinkedNotes)
                    ...linkedNotes.map((note) {
                      return Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NoteColors.get(note.colorKey).bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: NoteColors.get(note.colorKey).border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title.isNotEmpty ? note.title : 'Note',
                              style: GoogleFonts.fraunces(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.cream),
                            ),
                            const SizedBox(height: 4),
                            if (note.isChecklist)
                              ...note.items.map((item) {
                                return GestureDetector(
                                  onTap: () => provider.toggleChecklistItem(note.id, item.id),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.done ? Icons.check_box : Icons.check_box_outline_blank,
                                          size: 13,
                                          color: item.done ? colors.terracotta : colors.muted,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item.text,
                                            style: GoogleFonts.workSans(
                                              fontSize: 11,
                                              color: item.done ? colors.muted : colors.cream,
                                              decoration: item.done ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                            else
                              Text(note.content, style: GoogleFonts.workSans(fontSize: 11, color: colors.creamDim)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

          // Active Slot Live Progress Bar
          if (widget.isCurrent)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(colors.terracotta),
              ),
            ),

          // Task Journal Note (Expandable)
          if (_showJournalNote && isToday)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes for today: ${slot.label}',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.goldSoft,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: GoogleFonts.workSans(fontSize: 12.5, color: colors.cream),
                    decoration: InputDecoration(
                      hintText: 'Add reflections or details for this task...',
                      hintStyle: GoogleFonts.workSans(fontSize: 11.5, color: colors.muted),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => provider.setTaskJournalNote(slot.label, val),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    ),
    );
  }
}
