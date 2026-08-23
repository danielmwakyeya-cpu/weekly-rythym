import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/smart_reminder_model.dart';
import '../providers/schedule_provider.dart';
import '../services/notification_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAddReminderDialog(BuildContext context, ScheduleProvider provider) {
    final colors = provider.colors;
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime pickedDate = DateTime.now().add(const Duration(days: 14));
    bool month = true;
    bool fortnight = true;
    bool week = true;
    bool dayBefore = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: colors.plum,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.gold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Smart Advance Reminder', style: GoogleFonts.fraunces(fontSize: 18, color: colors.cream)),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: GoogleFonts.workSans(color: colors.cream, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Event / Milestone Name',
                  labelStyle: GoogleFonts.workSans(color: colors.muted),
                  hintText: 'e.g. Hospital Placement Term, Final Project',
                  hintStyle: GoogleFonts.workSans(color: colors.muted.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: pickedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (picked != null) {
                    setSheetState(() => pickedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.gold.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Date:', style: GoogleFonts.workSans(color: colors.muted, fontSize: 13)),
                      Text(DateFormat('EEE, MMM d, yyyy').format(pickedDate), style: GoogleFonts.workSans(color: colors.goldSoft, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Smart Lead Times:', style: GoogleFonts.workSans(color: colors.creamDim, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  FilterChip(
                    label: const Text('1 Month Before'),
                    selected: month,
                    onSelected: (v) => setSheetState(() => month = v),
                    selectedColor: colors.terracotta.withOpacity(0.3),
                  ),
                  FilterChip(
                    label: const Text('Fortnightly (2 Wks)'),
                    selected: fortnight,
                    onSelected: (v) => setSheetState(() => fortnight = v),
                    selectedColor: colors.terracotta.withOpacity(0.3),
                  ),
                  FilterChip(
                    label: const Text('1 Week Before'),
                    selected: week,
                    onSelected: (v) => setSheetState(() => week = v),
                    selectedColor: colors.terracotta.withOpacity(0.3),
                  ),
                  FilterChip(
                    label: const Text('1 Day Before'),
                    selected: dayBefore,
                    onSelected: (v) => setSheetState(() => dayBefore = v),
                    selectedColor: colors.terracotta.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.terracotta,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    provider.addReminder(
                      SmartReminderModel(
                        id: UniqueKey().toString(),
                        title: titleCtrl.text.trim(),
                        eventDate: pickedDate,
                        customNote: noteCtrl.text.trim(),
                        isMonthActive: month,
                        isFortnightActive: fortnight,
                        isWeekActive: week,
                        isDayActive: dayBefore,
                      ),
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Save Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final colors = provider.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: App Customization
          Text(
            'PERSONALIZATION',
            style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: colors.muted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),

          // App Title Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.gold.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('App Title', style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: colors.cream)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: colors.terracotta.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text('Customizable', style: GoogleFonts.workSans(fontSize: 10, color: colors.terracotta, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider.appTitle,
                  style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700, color: colors.goldSoft),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    final ctrl = TextEditingController(text: provider.appTitle);
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: colors.plum,
                        title: Text('Edit Title', style: GoogleFonts.fraunces(color: colors.cream)),
                        content: TextField(
                          controller: ctrl,
                          autofocus: true,
                          style: GoogleFonts.workSans(color: colors.cream),
                          decoration: InputDecoration(
                            hintText: 'e.g. Daniel\'s Rhythm, My Weekly Plan',
                            hintStyle: GoogleFonts.workSans(color: colors.muted),
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dCtx), child: Text('Cancel', style: TextStyle(color: colors.muted))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: colors.terracotta),
                            onPressed: () {
                              if (ctrl.text.trim().isNotEmpty) {
                                provider.setAppTitle(ctrl.text.trim());
                              }
                              Navigator.pop(dCtx);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Change Title'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.cream,
                    side: BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Smart Advance Reminders Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.gold.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Smart Advance Reminders', style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: colors.cream)),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: colors.goldSoft, size: 22),
                      onPressed: () => _showAddReminderDialog(context, provider),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Multi-tier advance warnings (1 month, fortnightly, 1 week, 1 day) for milestones and schedules.',
                  style: GoogleFonts.workSans(fontSize: 12, color: colors.muted),
                ),
                const SizedBox(height: 10),
                if (provider.reminders.isEmpty)
                  Text('No scheduled reminders yet. Tap "+" above to create one.', style: GoogleFonts.workSans(fontSize: 11.5, color: colors.muted.withOpacity(0.6)))
                else
                  ...provider.reminders.map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title, style: GoogleFonts.fraunces(fontSize: 13, fontWeight: FontWeight.w700, color: colors.cream)),
                                Text('${DateFormat('MMM d, yyyy').format(r.eventDate)} (${r.getUrgencyBadge(DateTime.now())})', style: GoogleFonts.workSans(fontSize: 11, color: colors.goldSoft)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 16, color: colors.rose),
                              onPressed: () => provider.deleteReminder(r.id),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pure Local Device Storage Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.gold.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: colors.sage),
                    const SizedBox(width: 8),
                    Text('On-Device Local Storage', style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: colors.cream)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '100% private. All your rhythm routines, notes, checklists, and journals are stored securely on this device without third-party servers.',
                  style: GoogleFonts.workSans(fontSize: 12, color: colors.muted, height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _storageMetric('Notes', '${provider.keepNotes.length}', colors),
                    const SizedBox(width: 8),
                    _storageMetric('Routines', '${provider.totalTasksThisWeek}', colors),
                    const SizedBox(width: 8),
                    _storageMetric('Reminders', '${provider.reminders.length}', colors),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Biometric App Lock Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.gold.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.fingerprint, size: 24, color: colors.terracotta),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biometric App Lock', style: GoogleFonts.fraunces(fontSize: 15, fontWeight: FontWeight.w700, color: colors.cream)),
                      Text(
                        'Require fingerprint or face to open the app',
                        style: GoogleFonts.workSans(fontSize: 11, color: colors.muted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.biometricLockEnabled,
                  onChanged: (v) {
                    HapticService.selectionClick();
                    provider.setBiometricLock(v);
                  },
                  activeColor: colors.terracotta,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme Palette Switcher
          Text(
            'COLOR THEMES',
            style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: colors.muted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          ...AppThemes.allThemes.map((theme) {
            final isSelected = provider.currentThemeId == theme.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colors.plum : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? colors.terracotta : Colors.white.withOpacity(0.08),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: ListTile(
                onTap: () => provider.setTheme(theme.id),
                title: Text(
                  theme.name,
                  style: GoogleFonts.fraunces(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? colors.cream : colors.creamDim,
                  ),
                ),
                subtitle: Text(
                  theme.description,
                  style: GoogleFonts.workSans(fontSize: 11, color: colors.muted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _colorDot(theme.colors.bg),
                    const SizedBox(width: 4),
                    _colorDot(theme.colors.plum),
                    const SizedBox(width: 4),
                    _colorDot(theme.colors.terracotta),
                    const SizedBox(width: 4),
                    _colorDot(theme.colors.gold),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle, color: colors.terracotta, size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Backup & Restore
          Text(
            'DATA BACKUP & RESTORE',
            style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: colors.muted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    HapticService.lightTap();
                    try {
                      final json = provider.exportJson();
                      final dir = await getTemporaryDirectory();
                      final file = File('${dir.path}/weekly_rhythm_backup.json');
                      await file.writeAsString(json);
                      await Share.shareXFiles(
                        [XFile(file.path)],
                        subject: 'Weekly Rhythm Backup',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        // Fallback to clipboard
                        Clipboard.setData(ClipboardData(text: provider.exportJson()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup copied to clipboard!')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Export'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.cream,
                    side: BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    HapticService.lightTap();
                    try {
                      final result = await FilePickerPlatform.instance.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null && result.isNotEmpty && result.first.path != null) {
                        final file = File(result.first.path!);
                        final jsonStr = await file.readAsString();
                        final success = await provider.importJson(jsonStr);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? 'Data imported successfully!' : 'Invalid backup file.')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to import backup.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Import'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.cream,
                    side: BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _storageMetric(String label, String value, AppColors colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700, color: colors.goldSoft)),
            Text(label, style: GoogleFonts.workSans(fontSize: 10, color: colors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
    );
  }
}
