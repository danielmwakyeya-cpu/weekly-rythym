import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class QuickTemplatesBar extends StatelessWidget {
  final AppColors colors;
  final Function(SlotModel) onAddTemplate;

  const QuickTemplatesBar({
    super.key,
    required this.colors,
    required this.onAddTemplate,
  });

  static final List<SlotModel> _templates = [
    SlotModel(time: '5:30 â€“ 6:30 PM', label: 'Doom scroll time', desc: 'Decompress, guilt-free scrolling', kind: SlotKind.normal),
    SlotModel(time: '6:30 â€“ 7:30 PM', label: 'Study time', desc: 'Coursework and focused reading', kind: SlotKind.normal),
    SlotModel(time: '7:45 â€“ 8:45 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
    SlotModel(time: '6:30 â€“ 8:30 PM', label: 'Rest / nap', desc: 'Bank some sleep and recharge', kind: SlotKind.normal),
    SlotModel(time: '5:00 â€“ 5:45 PM', label: 'Walk & fresh air', desc: 'Step outside and move', kind: SlotKind.normal),
    SlotModel(time: '4:00 â€“ 4:30 PM', label: 'Tea & snack', desc: 'Quick afternoon refuel', kind: SlotKind.normal),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'QUICK ADD TEMPLATES',
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _templates.map((tpl) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  backgroundColor: Colors.white.withOpacity(0.04),
                  side: BorderSide(color: colors.gold.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  label: Text(
                    '+ ${tpl.label}',
                    style: GoogleFonts.workSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.goldSoft,
                    ),
                  ),
                  onPressed: () => onAddTemplate(tpl.copyWith()),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
