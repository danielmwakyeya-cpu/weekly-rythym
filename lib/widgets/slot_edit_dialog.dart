import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class SlotEditDialog extends StatefulWidget {
  final AppColors colors;
  final SlotModel? slot;
  final Function(SlotModel) onSave;
  final VoidCallback? onDelete;

  const SlotEditDialog({
    super.key,
    required this.colors,
    this.slot,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<SlotEditDialog> createState() => _SlotEditDialogState();
}

class _SlotEditDialogState extends State<SlotEditDialog> {
  late TextEditingController _timeCtrl;
  late TextEditingController _labelCtrl;
  late TextEditingController _descCtrl;
  late SlotKind _kind;

  @override
  void initState() {
    super.initState();
    _timeCtrl = TextEditingController(text: widget.slot?.time ?? '8:00 AM');
    _labelCtrl = TextEditingController(text: widget.slot?.label ?? '');
    _descCtrl = TextEditingController(text: widget.slot?.desc ?? '');
    _kind = widget.slot?.kind ?? SlotKind.normal;
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _labelCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isNew = widget.slot == null;

    return Dialog(
      backgroundColor: colors.plum,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.gold.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isNew ? 'Add a task' : 'Edit task',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.cream,
                ),
              ),
              const SizedBox(height: 16),

              // Time
              Text('Time (e.g. 8:00 AM, 9:00 AM â€“ 5:00 PM)', style: GoogleFonts.workSans(fontSize: 11, color: colors.muted)),
              const SizedBox(height: 4),
              TextField(
                controller: _timeCtrl,
                style: GoogleFonts.workSans(color: colors.cream, fontSize: 13.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              // Label
              Text('Task Name', style: GoogleFonts.workSans(fontSize: 11, color: colors.muted)),
              const SizedBox(height: 4),
              TextField(
                controller: _labelCtrl,
                style: GoogleFonts.workSans(color: colors.cream, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'e.g. Crochet time, Study',
                  hintStyle: GoogleFonts.workSans(color: colors.muted.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              // Desc
              Text('Description / Note', style: GoogleFonts.workSans(fontSize: 11, color: colors.muted)),
              const SizedBox(height: 4),
              TextField(
                controller: _descCtrl,
                style: GoogleFonts.workSans(color: colors.cream, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'e.g. Hands busy, mind quiet',
                  hintStyle: GoogleFonts.workSans(color: colors.muted.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.gold)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),

              // Kind Selector
              Text('Task type', style: GoogleFonts.workSans(fontSize: 11, color: colors.muted)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _kindChip('Flexible', SlotKind.normal, colors),
                  const SizedBox(width: 8),
                  _kindChip('Set time', SlotKind.fixed, colors),
                  const SizedBox(width: 8),
                  _kindChip('Overnight', SlotKind.night, colors),
                ],
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isNew && widget.onDelete != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      label: Text('Delete', style: GoogleFonts.workSans(color: Colors.redAccent, fontSize: 13)),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: GoogleFonts.workSans(color: colors.muted)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.terracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          if (_labelCtrl.text.trim().isEmpty) return;
                          final newSlot = SlotModel(
                            time: _timeCtrl.text.trim(),
                            label: _labelCtrl.text.trim(),
                            desc: _descCtrl.text.trim(),
                            kind: _kind,
                            done: widget.slot?.done ?? false,
                          );
                          widget.onSave(newSlot);
                          Navigator.pop(context);
                        },
                        child: Text(isNew ? 'Add' : 'Save', style: GoogleFonts.workSans(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kindChip(String title, SlotKind kind, AppColors colors) {
    final selected = _kind == kind;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kind = kind),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.terracotta.withOpacity(0.3) : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colors.terracotta : colors.gold.withOpacity(0.2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.workSans(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? colors.goldSoft : colors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
