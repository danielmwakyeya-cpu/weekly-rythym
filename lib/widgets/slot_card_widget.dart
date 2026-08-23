import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../services/haptic_service.dart';

class SlotCardWidget extends StatefulWidget {
  final String day;
  final int index;
  final bool isCurrent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SlotCardWidget({
    super.key,
    required this.day,
    required this.index,
    required this.isCurrent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SlotCardWidget> createState() => _SlotCardWidgetState();
}

class _SlotCardWidgetState extends State<SlotCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _cardPressCtrl;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    _cardPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _cardScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _cardPressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardPressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;
    final daySchedule = provider.schedule[widget.day];
    if (daySchedule == null || widget.index >= daySchedule.slots.length) return const SizedBox.shrink();
    final slot = daySchedule.slots[widget.index];

    return Dismissible(
      key: ValueKey('dismiss_${widget.day}_${slot.label}_${widget.index}'),
      direction: slot.done ? DismissDirection.none : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        HapticService.mediumImpact();
        provider.toggleSlotDone(widget.day, widget.index);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colors.sage.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.sage.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: colors.sage, size: 24),
            const SizedBox(width: 10),
            Text(
              'Completed!',
              style: GoogleFonts.outfit(color: colors.sage, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
      child: Semantics(
        label: '${slot.label}, ${slot.done ? "completed" : "pending"}, ${slot.time}',
        child: AnimatedBuilder(
          animation: _cardScale,
          builder: (context, child) => Transform.scale(
            scale: _cardScale.value,
            child: child,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isCurrent
                    ? [
                        colors.terracotta.withValues(alpha: 0.16),
                        colors.plum.withValues(alpha: 0.4),
                      ]
                    : (slot.done
                        ? [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.1),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.015),
                          ]),
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isCurrent
                    ? colors.terracotta.withValues(alpha: 0.6)
                    : (slot.done
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.1)),
                width: widget.isCurrent ? 1.5 : 1.0,
              ),
              boxShadow: widget.isCurrent
                  ? [
                      BoxShadow(
                        color: colors.terracotta.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTapDown: (_) => _cardPressCtrl.forward(),
                onTapUp: (_) {
                  _cardPressCtrl.reverse();
                  widget.onEdit();
                },
                onTapCancel: () => _cardPressCtrl.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag handle icon
                      ReorderableDragStartListener(
                        index: widget.index,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.drag_indicator,
                            color: colors.muted.withValues(alpha: 0.45),
                            size: 20,
                          ),
                        ),
                      ),

                      // Bouncing Animated Checkbox
                      _BouncingCheckbox(
                        isDone: slot.done,
                        colors: colors,
                        onToggle: () {
                          HapticService.lightTap();
                          provider.toggleSlotDone(widget.day, widget.index);
                        },
                      ),
                      const SizedBox(width: 14),

                      // Slot Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time + Pills + Now badge
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.gold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: colors.gold.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    slot.time,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors.goldSoft,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                if (widget.isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [colors.terracotta, colors.gold],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.terracotta.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.only(right: 4),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'NOW',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (slot.kind != SlotKind.normal)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: slot.kind == SlotKind.fixed
                                          ? colors.sage.withValues(alpha: 0.18)
                                          : colors.terracotta.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: slot.kind == SlotKind.fixed
                                            ? colors.sage.withValues(alpha: 0.35)
                                            : colors.terracotta.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      slot.kind.displayName.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: slot.kind == SlotKind.fixed ? colors.sage : colors.terracotta,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            // Label
                            Text(
                              slot.label,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: slot.done ? colors.muted.withValues(alpha: 0.6) : colors.cream,
                                decoration: slot.done ? TextDecoration.lineThrough : null,
                                decorationColor: colors.muted,
                              ),
                            ),

                            // Description
                            if (slot.desc.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                slot.desc,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: slot.done
                                      ? colors.muted.withValues(alpha: 0.4)
                                      : colors.muted.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Edit button
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: colors.muted.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onPressed: widget.onEdit,
                        tooltip: 'Edit routine item',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BouncingCheckbox extends StatefulWidget {
  final bool isDone;
  final dynamic colors;
  final VoidCallback onToggle;

  const _BouncingCheckbox({
    required this.isDone,
    required this.colors,
    required this.onToggle,
  });

  @override
  State<_BouncingCheckbox> createState() => _BouncingCheckboxState();
}

class _BouncingCheckboxState extends State<_BouncingCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 50),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant _BouncingCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDone != widget.isDone && widget.isDone) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: widget.isDone ? _scale.value : 1.0,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            gradient: widget.isDone
                ? LinearGradient(
                    colors: [colors.terracotta, colors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isDone ? null : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isDone ? Colors.transparent : colors.gold.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: widget.isDone
                ? [
                    BoxShadow(
                      color: colors.terracotta.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.isDone
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
      ),
    );
  }
}
