import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/keep_note_model.dart';
import '../providers/schedule_provider.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/app_theme.dart';

class KeepScreen extends StatefulWidget {
  const KeepScreen({super.key});

  @override
  State<KeepScreen> createState() => _KeepScreenState();
}

class _KeepScreenState extends State<KeepScreen> {
  String _searchQuery = '';
  String _selectedTag = 'all';

  void _showNoteEditor(BuildContext context, ScheduleProvider provider, [KeepNoteModel? existingNote, bool startAsChecklist = false]) {
    final colors = provider.colors;
    final isNew = existingNote == null;

    final titleCtrl = TextEditingController(text: existingNote?.title ?? '');
    final contentCtrl = TextEditingController(text: existingNote?.content ?? '');
    final tagCtrl = TextEditingController();

    String colorKey = existingNote?.colorKey ?? 'default';
    bool isPinned = existingNote?.isPinned ?? false;
    List<ChecklistItem> items = existingNote != null
        ? existingNote.items.map((i) => i.copyWith()).toList()
        : (startAsChecklist ? [ChecklistItem(id: UniqueKey().toString(), text: '')] : []);
    List<String> tags = existingNote != null ? List.from(existingNote.tags) : [];
    List<String> linkedTasks = existingNote != null ? List.from(existingNote.linkedTaskLabels) : [];
    List<String> linkedDays = existingNote != null ? List.from(existingNote.linkedDays) : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final noteColor = NoteColors.get(colorKey);

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 16,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: noteColor.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: noteColor.border, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNew ? (items.isNotEmpty ? 'New Checklist' : 'New Note') : 'Edit Note',
                      style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: colors.cream),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: isPinned ? colors.gold : colors.muted),
                          onPressed: () => setModalState(() => isPinned = !isPinned),
                        ),
                        if (!isNew)
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colors.rose),
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.deleteKeepNote(existingNote.id);
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.check, color: colors.goldSoft),
                          onPressed: () {
                            final title = titleCtrl.text.trim();
                            final content = contentCtrl.text.trim();
                            final validItems = items.where((i) => i.text.trim().isNotEmpty).toList();

                            if (title.isNotEmpty || content.isNotEmpty || validItems.isNotEmpty) {
                              final note = KeepNoteModel(
                                id: existingNote?.id ?? UniqueKey().toString(),
                                title: title,
                                content: content,
                                colorKey: colorKey,
                                isPinned: isPinned,
                                items: validItems,
                                tags: tags,
                                linkedTaskLabels: linkedTasks,
                                linkedDays: linkedDays,
                              );
                              if (isNew) {
                                provider.addKeepNote(note);
                              } else {
                                provider.updateKeepNote(note);
                              }
                            }
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),

                // Title Input
                TextField(
                  controller: titleCtrl,
                  style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: colors.cream),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: GoogleFonts.fraunces(color: colors.muted.withOpacity(0.5), fontSize: 18),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                // Content / Checklist Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text note area
                        if (items.isEmpty)
                          TextField(
                            controller: contentCtrl,
                            maxLines: null,
                            style: GoogleFonts.workSans(fontSize: 14, color: colors.creamDim),
                            decoration: InputDecoration(
                              hintText: 'Note details...',
                              hintStyle: GoogleFonts.workSans(color: colors.muted.withOpacity(0.5)),
                              border: InputBorder.none,
                            ),
                          )
                        else
                          // Checklist items
                          ...items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setModalState(() => item.done = !item.done),
                                    child: Icon(
                                      item.done ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: item.done ? colors.terracotta : colors.muted,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: item.text,
                                      style: GoogleFonts.workSans(
                                        fontSize: 13.5,
                                        color: item.done ? colors.muted : colors.cream,
                                        decoration: item.done ? TextDecoration.lineThrough : null,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (val) => item.text = val,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 16, color: colors.muted.withOpacity(0.6)),
                                    onPressed: () => setModalState(() => items.removeAt(i)),
                                  ),
                                ],
                              ),
                            );
                          }),

                        if (items.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => setModalState(() {
                              items.add(ChecklistItem(id: UniqueKey().toString(), text: ''));
                            }),
                            icon: Icon(Icons.add, size: 16, color: colors.gold),
                            label: Text('List item', style: GoogleFonts.workSans(fontSize: 13, color: colors.gold)),
                          ),

                        const SizedBox(height: 16),

                        // Tags display
                        if (tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags.map((t) => Chip(
                                  label: Text(t, style: GoogleFonts.workSans(fontSize: 11, color: colors.goldSoft)),
                                  backgroundColor: Colors.black26,
                                  deleteIcon: const Icon(Icons.close, size: 12),
                                  onDeleted: () => setModalState(() => tags.remove(t)),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                )).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Smart Linking Info
                        if (linkedTasks.isNotEmpty || linkedDays.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link, size: 16, color: colors.sage),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Linked to: ${[...linkedTasks, ...linkedDays].join(', ')}',
                                    style: GoogleFonts.workSans(fontSize: 11.5, color: colors.sage),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar: Colors, Tags & Smart Linking
                Row(
                  children: [
                    // Color Pickers
                    ...NoteColors.options.map((opt) {
                      final selected = colorKey == opt.key;
                      return GestureDetector(
                        onTap: () => setModalState(() => colorKey = opt.key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: opt.bg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? colors.gold : opt.border,
                              width: selected ? 2.0 : 1.0,
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),

                    // Tag Adder
                    IconButton(
                      icon: Icon(Icons.label_outline, color: colors.muted),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            backgroundColor: colors.plum,
                            title: Text('Add Label / Tag', style: GoogleFonts.fraunces(color: colors.cream)),
                            content: TextField(
                              controller: tagCtrl,
                              autofocus: true,
                              style: GoogleFonts.workSans(color: colors.cream),
                              decoration: InputDecoration(
                                hintText: 'e.g. #groceries, #placement, #study',
                                hintStyle: GoogleFonts.workSans(color: colors.muted),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  var tag = tagCtrl.text.trim();
                                  if (tag.isNotEmpty) {
                                    if (!tag.startsWith('#')) tag = '#$tag';
                                    setModalState(() {
                                      if (!tags.contains(tag)) tags.add(tag);
                                    });
                                  }
                                  tagCtrl.clear();
                                  Navigator.pop(dCtx);
                                },
                                child: Text('Add', style: TextStyle(color: colors.gold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Convert to / from checklist
                    IconButton(
                      icon: Icon(items.isEmpty ? Icons.checklist : Icons.notes, color: colors.muted),
                      onPressed: () => setModalState(() {
                        if (items.isEmpty) {
                          final lines = contentCtrl.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
                          items = lines.isNotEmpty
                              ? lines.map((l) => ChecklistItem(id: UniqueKey().toString(), text: l.trim())).toList()
                              : [ChecklistItem(id: UniqueKey().toString(), text: '')];
                          contentCtrl.clear();
                        } else {
                          contentCtrl.text = items.map((i) => i.text).join('\n');
                          items.clear();
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    var notes = provider.activeKeepNotes;

    // Filter by query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      notes = notes.where((n) {
        final inTitle = n.title.toLowerCase().contains(q);
        final inContent = n.content.toLowerCase().contains(q);
        final inTags = n.tags.any((t) => t.toLowerCase().contains(q));
        final inItems = n.items.any((i) => i.text.toLowerCase().contains(q));
        return inTitle || inContent || inTags || inItems;
      }).toList();
    }

    // Filter by tag
    if (_selectedTag != 'all') {
      notes = notes.where((n) => n.tags.contains(_selectedTag)).toList();
    }

    final pinned = notes.where((n) => n.isPinned).toList();
    final unpinned = notes.where((n) => !n.isPinned).toList();
    final allTags = provider.allKeepTags;

    if (provider.isLoading) {
      return ShimmerKeepGrid(
        baseColor: colors.plum.withOpacity(0.5),
        highlightColor: colors.plumLight,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Tag Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.gold.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: colors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.workSans(fontSize: 13, color: colors.cream),
                      decoration: InputDecoration(
                        hintText: 'Search notes, checklists & tags...',
                        hintStyle: GoogleFonts.workSans(fontSize: 13, color: colors.muted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: Icon(Icons.close, size: 16, color: colors.muted),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tag Filter Chips
            if (allTags.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _filterChip('all', 'All', colors),
                    ...allTags.map((t) => _filterChip(t, t, colors)),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Main Notes Grid
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sticky_note_2_outlined, size: 54, color: colors.muted.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text('No notes found', style: GoogleFonts.fraunces(fontSize: 17, color: colors.cream)),
                          const SizedBox(height: 4),
                          Text('Tap "+" below to create your first note or checklist', style: GoogleFonts.workSans(fontSize: 12, color: colors.muted)),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (pinned.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 4),
                              child: Text(
                                'PINNED',
                                style: GoogleFonts.workSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.muted, letterSpacing: 1.0),
                              ),
                            ),
                          ),
                          _buildMasonryGrid(pinned, provider, colors),
                          if (unpinned.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                                child: Text(
                                  'OTHERS',
                                  style: GoogleFonts.workSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: colors.muted, letterSpacing: 1.0),
                                ),
                              ),
                            ),
                        ],
                        if (unpinned.isNotEmpty) _buildMasonryGrid(unpinned, provider, colors),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // FAB Action Buttons: + Note and + Checklist
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'fab_checklist',
              backgroundColor: colors.plumLight,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colors.gold.withOpacity(0.3))),
              icon: Icon(Icons.checklist, size: 18, color: colors.goldSoft),
              label: Text('Checklist', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600, color: colors.goldSoft)),
              onPressed: () => _showNoteEditor(context, provider, null, true),
            ),
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              heroTag: 'fab_note',
              backgroundColor: colors.terracotta,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text('Note', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              onPressed: () => _showNoteEditor(context, provider, null, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String tagKey, String label, AppColors colors) {
    final selected = _selectedTag == tagKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedTag = tagKey),
        backgroundColor: Colors.white.withOpacity(0.04),
        selectedColor: colors.terracotta.withOpacity(0.25),
        labelStyle: GoogleFonts.workSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colors.goldSoft : colors.muted,
        ),
        side: BorderSide(color: selected ? colors.terracotta : Colors.white12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildMasonryGrid(List<KeepNoteModel> list, ScheduleProvider provider, AppColors colors) {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childCount: list.length,
      itemBuilder: (context, index) {
        final note = list[index];
        final noteColor = NoteColors.get(note.colorKey);

        return GestureDetector(
          onTap: () => _showNoteEditor(context, provider, note),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: noteColor.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: noteColor.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Pin icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty)
                      Expanded(
                        child: Text(
                          note.title,
                          style: GoogleFonts.fraunces(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: colors.cream,
                          ),
                        ),
                      ),
                    if (note.isPinned)
                      Icon(Icons.push_pin, size: 14, color: colors.goldSoft),
                  ],
                ),
                if (note.title.isNotEmpty && (note.content.isNotEmpty || note.items.isNotEmpty))
                  const SizedBox(height: 6),

                // Note Content
                if (!note.isChecklist && note.content.isNotEmpty)
                  Text(
                    note.content,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colors.creamDim,
                      height: 1.35,
                    ),
                  ),

                // Checklist preview (first 4 items)
                if (note.isChecklist) ...[
                  ...note.items.take(4).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => provider.toggleChecklistItem(note.id, item.id),
                              child: Icon(
                                item.done ? Icons.check_box : Icons.check_box_outline_blank,
                                size: 14,
                                color: item.done ? colors.terracotta : colors.muted,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                item.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.workSans(
                                  fontSize: 11.5,
                                  color: item.done ? colors.muted : colors.cream,
                                  decoration: item.done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (note.items.length > 4)
                    Text(
                      '+${note.items.length - 4} more items',
                      style: GoogleFonts.workSans(fontSize: 10, color: colors.muted, fontStyle: FontStyle.italic),
                    ),
                ],

                // Tags & Smart Link Pills
                if (note.tags.isNotEmpty || note.linkedTaskLabels.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...note.tags.take(2).map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                            child: Text(t, style: GoogleFonts.workSans(fontSize: 9.5, color: colors.goldSoft)),
                          )),
                      ...note.linkedTaskLabels.take(1).map((l) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: colors.sage.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link, size: 9, color: colors.sage),
                                const SizedBox(width: 2),
                                Text(l, style: GoogleFonts.workSans(fontSize: 9.5, color: colors.sage)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
