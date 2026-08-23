import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/schedule_model.dart';
import '../models/keep_note_model.dart';
import '../models/smart_reminder_model.dart';
import '../services/default_schedule.dart';
import '../services/storage_service.dart';
import '../services/alarm_sound_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';

class UndoAction {
  final String message;
  final VoidCallback undo;

  UndoAction({required this.message, required this.undo});
}

class NextUpInfo {
  final SlotModel slot;
  final int startMin;
  final String timeLabel;
  final String diffText;

  NextUpInfo({
    required this.slot,
    required this.startMin,
    required this.timeLabel,
    required this.diffText,
  });
}

class ScheduleProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  // 1. App Title
  String _appTitle = 'Weekly Rhythm';
  String get appTitle => _appTitle;

  Map<String, DayModel> _schedule = DefaultSchedule.getDefaults();
  Map<String, DayModel> get schedule => _schedule;

  String _activeDay = 'Monday';
  String get activeDay => _activeDay;

  String _currentThemeId = 'blush';
  String get currentThemeId => _currentThemeId;

  Color _customAccent = const Color(0xFFE8A4BD);
  Color get customAccent => _customAccent;

  AppColors get colors => AppThemes.getTheme(_currentThemeId, customAccent: _customAccent).colors;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // 2. Keep Notes & Checklists
  List<KeepNoteModel> _keepNotes = [];
  List<KeepNoteModel> get keepNotes => _keepNotes;
  List<KeepNoteModel> get activeKeepNotes => _keepNotes.where((n) => !n.isArchived).toList();
  List<KeepNoteModel> get pinnedNotes => activeKeepNotes.where((n) => n.isPinned).toList();
  List<KeepNoteModel> get unpinnedNotes => activeKeepNotes.where((n) => !n.isPinned).toList();
  List<KeepNoteModel> get archivedNotes => _keepNotes.where((n) => n.isArchived).toList();

  // 3. Smart Reminders
  List<SmartReminderModel> _reminders = [];
  List<SmartReminderModel> get reminders => _reminders;

  // 4. Timer & Alarm State
  int _customTimerDurationSeconds = 30 * 60;
  int get customTimerDurationSeconds => _customTimerDurationSeconds;
  bool _isAlarmRinging = false;
  bool get isAlarmRinging => _isAlarmRinging;

  // 5. Celebration State
  bool _showCelebration = false;
  bool get showCelebration => _showCelebration;

  // 6. Biometric App Lock
  bool _biometricLockEnabled = false;
  bool get biometricLockEnabled => _biometricLockEnabled;

  // 7. Streak & Badges
  int _longestStreak = 0;
  int get longestStreak => _longestStreak;
  List<String> _earnedBadges = [];
  List<String> get earnedBadges => _earnedBadges;

  // History & stats
  List<WeekHistoryItem> _weekHistory = [];
  List<WeekHistoryItem> get weekHistory => _weekHistory;

  Map<String, List<bool>> _slotHistory = {};
  Map<String, List<int>> _dayHistory = {};
  Map<String, String> _moodLog = {};
  Map<String, dynamic> _journal = {};
  Map<String, String> _dismissedInsights = {};

  String _currentWeekKey = '';
  Timer? _periodicTimer;

  // Undo Toast state
  UndoAction? _currentUndo;
  UndoAction? get currentUndo => _currentUndo;
  Timer? _undoTimer;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ScheduleProvider() {
    _initToday();
    _currentWeekKey = _getWeekKey();
    _loadFromStorage();

    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkRollovers();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _undoTimer?.cancel();
    AlarmSoundService.stopAlarm();
    super.dispose();
  }

  String get todayName => DateFormat('EEEE').format(DateTime.now());
  String get todayDateKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _initToday() {
    final nowDay = todayName;
    if (DefaultSchedule.days.contains(nowDay)) {
      _activeDay = nowDay;
    } else {
      _activeDay = 'Monday';
    }
  }

  String _getWeekKey([DateTime? d]) {
    final date = d ?? DateTime.now();
    final dayOffset = date.weekday - 1;
    final monday = date.subtract(Duration(days: dayOffset));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  void setAppTitle(String newTitle) {
    final trimmed = newTitle.trim();
    if (trimmed.isNotEmpty) {
      _appTitle = trimmed;
      _save();
      notifyListeners();
    }
  }

  void setActiveDay(String day) {
    if (DefaultSchedule.days.contains(day)) {
      _activeDay = day;
      notifyListeners();
    }
  }

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // --- STATS COMPUTATION ---
  int get totalTasksThisWeek => _schedule.values.fold(0, (sum, d) => sum + d.totalCount);
  int get doneTasksThisWeek => _schedule.values.fold(0, (sum, d) => sum + d.doneCount);
  int get weekCompletionPct => totalTasksThisWeek == 0 ? 0 : ((doneTasksThisWeek / totalTasksThisWeek) * 100).round();
  int get fullDaysThisWeek => _schedule.values.where((d) => d.isFullyDone).length;

  int get dayStreak {
    final nowDay = todayName;
    final idxToday = DefaultSchedule.days.indexOf(nowDay);
    if (idxToday == -1) return 0;

    final todaySlots = _schedule[nowDay]?.slots ?? [];
    final todayDone = todaySlots.isNotEmpty && todaySlots.every((s) => s.done);

    int streak = 0;
    for (int i = todayDone ? idxToday : idxToday - 1; i >= 0; i--) {
      final day = DefaultSchedule.days[i];
      final slots = _schedule[day]?.slots ?? [];
      if (slots.isNotEmpty && slots.every((s) => s.done)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // --- NEXT UP BANNER ---
  NextUpInfo? get nextUpInfo {
    if (_activeDay != todayName) return null;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final slots = _schedule[_activeDay]?.slots ?? [];

    SlotModel? nextSlot;
    int? nextStart;

    for (final s in slots) {
      final t = s.parsedTime;
      if (t == null || t.startMin == null) continue;
      if (t.startMin! >= nowMin && (nextStart == null || t.startMin! < nextStart)) {
        nextStart = t.startMin;
        nextSlot = s;
      }
    }

    if (nextSlot == null || nextStart == null) return null;

    final diff = nextStart - nowMin;
    final diffText = diff <= 0 ? 'now' : (diff < 60 ? 'in $diff min' : 'in ${(diff / 60).toStringAsFixed(1)} hr');
    final timeStart = ParsedTime.formatClock(nextStart);

    return NextUpInfo(
      slot: nextSlot,
      startMin: nextStart,
      timeLabel: timeStart,
      diffText: diffText,
    );
  }

  // Current slot index & progress
  int get currentSlotIndex {
    if (_activeDay != todayName) return -1;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final slots = _schedule[_activeDay]?.slots ?? [];

    int currentIdx = -1;
    int? currentStart;

    for (int i = 0; i < slots.length; i++) {
      final t = slots[i].parsedTime;
      if (t == null || t.startMin == null) continue;
      if (t.startMin! <= nowMin && (currentStart == null || t.startMin! > currentStart)) {
        currentStart = t.startMin;
        currentIdx = i;
      }
    }
    return currentIdx;
  }

  double getSlotProgress(int index) {
    final slots = _schedule[_activeDay]?.slots ?? [];
    if (index < 0 || index >= slots.length) return 0.0;
    final t = slots[index].parsedTime;
    if (t == null || t.startMin == null) return 0.0;

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final start = t.startMin!;
    int end = t.endMin ?? (start + 60);

    if (nowMin <= start) return 0.0;
    if (nowMin >= end) return 1.0;
    return ((nowMin - start) / (end - start)).clamp(0.0, 1.0);
  }

  // --- ACTIONS ---
  void toggleSlotDone(String day, int index) {
    final dayModel = _schedule[day];
    if (dayModel == null || index >= dayModel.slots.length) return;

    final slot = dayModel.slots[index];
    slot.done = !slot.done;
    HapticFeedback.lightImpact();

    // Check if all tasks for active day are now complete → trigger celebration
    if (slot.done && dayModel.isFullyDone && dayModel.slots.isNotEmpty) {
      _showCelebration = true;
      _updateStreakAndBadges();
    }

    _save();
    notifyListeners();
  }

  void dismissCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  void setBiometricLock(bool enabled) {
    _biometricLockEnabled = enabled;
    _save();
    notifyListeners();
  }

  void _updateStreakAndBadges() {
    final streak = dayStreak;
    if (streak > _longestStreak) {
      _longestStreak = streak;
    }

    final newBadges = <String>[];
    if (streak >= 3 && !_earnedBadges.contains('🔥 3-Day Streak')) {
      newBadges.add('🔥 3-Day Streak');
    }
    if (streak >= 5 && !_earnedBadges.contains('⚡ 5-Day Fire')) {
      newBadges.add('⚡ 5-Day Fire');
    }
    if (streak >= 7 && !_earnedBadges.contains('💪 Week Warrior')) {
      newBadges.add('💪 Week Warrior');
    }
    if (fullDaysThisWeek >= 7 && !_earnedBadges.contains('🏆 Perfect Week')) {
      newBadges.add('🏆 Perfect Week');
    }
    if (_weekHistory.length >= 4 && !_earnedBadges.contains('🌟 Month Master')) {
      final allPerfect = _weekHistory.take(4).every((w) => w.doneTasks == w.totalTasks);
      if (allPerfect) newBadges.add('🌟 Month Master');
    }

    _earnedBadges.addAll(newBadges);
  }

  void addSlot(String day, SlotModel slot) {
    final dayModel = _schedule[day];
    if (dayModel == null) return;
    dayModel.slots.add(slot);
    _sortDaySlots(day);
    _save();
    notifyListeners();
  }

  void updateSlot(String day, int index, SlotModel newSlot) {
    final dayModel = _schedule[day];
    if (dayModel == null || index >= dayModel.slots.length) return;
    dayModel.slots[index] = newSlot;
    _sortDaySlots(day);
    _save();
    notifyListeners();
  }

  void deleteSlot(String day, int index) {
    final dayModel = _schedule[day];
    if (dayModel == null || index >= dayModel.slots.length) return;

    final removed = dayModel.slots.removeAt(index);
    _save();
    notifyListeners();

    showUndo('Deleted "${removed.label}"', () {
      final target = _schedule[day];
      if (target != null) {
        target.slots.insert(index.clamp(0, target.slots.length), removed);
        _save();
        notifyListeners();
      }
    });
  }

  void reorderSlots(String day, int oldIndex, int newIndex) {
    final dayModel = _schedule[day];
    if (dayModel == null) return;

    if (newIndex > oldIndex) newIndex -= 1;
    final item = dayModel.slots.removeAt(oldIndex);
    dayModel.slots.insert(newIndex, item);

    _save();
    notifyListeners();
  }

  void setDayNote(String day, String note) {
    final dayModel = _schedule[day];
    if (dayModel == null) return;
    dayModel.note = note;
    _save();
    notifyListeners();
  }

  void duplicateDay(String fromDay, String toDay) {
    final src = _schedule[fromDay];
    final dest = _schedule[toDay];
    if (src == null || dest == null) return;

    final prevSlots = dest.slots.map((s) => s.copyWith()).toList();
    final prevNote = dest.note;

    dest.slots = src.slots.map((s) => s.copyWith(done: false)).toList();
    dest.note = src.note;

    _save();
    notifyListeners();

    showUndo('Duplicated $fromDay to $toDay', () {
      final d = _schedule[toDay];
      if (d != null) {
        d.slots = prevSlots;
        d.note = prevNote;
        _save();
        notifyListeners();
      }
    });
  }

  void resetDayToDefault(String day) {
    final defaults = DefaultSchedule.getDefaults();
    if (!defaults.containsKey(day)) return;

    final currentDay = _schedule[day];
    final prevSlots = currentDay?.slots.map((s) => s.copyWith()).toList() ?? [];
    final prevNote = currentDay?.note ?? '';

    _schedule[day] = defaults[day]!;
    _sortDaySlots(day);
    _save();
    notifyListeners();

    showUndo('Reset $day to default rhythm', () {
      final d = _schedule[day];
      if (d != null) {
        d.slots = prevSlots;
        d.note = prevNote;
        _save();
        notifyListeners();
      }
    });
  }

  void resetWeekToDefaults() {
    final prev = _schedule.map((k, v) => MapEntry(k, v.copyWith()));
    _schedule = DefaultSchedule.getDefaults();
    for (final d in _schedule.keys) {
      _sortDaySlots(d);
    }
    _save();
    notifyListeners();

    showUndo('Reset full week to defaults', () {
      _schedule = prev;
      _save();
      notifyListeners();
    });
  }

  void resetWeekChecks() {
    for (final day in _schedule.values) {
      for (final s in day.slots) {
        s.done = false;
      }
    }
    _save();
    notifyListeners();
  }

  void resetWeekCompletion() => resetWeekChecks();

  String getFormattedScheduleText() {
    final buf = StringBuffer();
    for (final day in DefaultSchedule.days) {
      final d = _schedule[day];
      if (d == null) continue;
      buf.writeln('--- ${d.dayName} ---');
      if (d.note.isNotEmpty) buf.writeln('Note: ${d.note}');
      for (final s in d.slots) {
        final status = s.done ? '[x]' : '[ ]';
        buf.writeln('$status ${s.time} - ${s.label}: ${s.desc}');
      }
      buf.writeln();
    }
    return buf.toString();
  }

  void _sortDaySlots(String day) {
    final d = _schedule[day];
    if (d == null) return;
    d.slots.sort((a, b) {
      final aStart = a.parsedTime?.startMin ?? 9999;
      final bStart = b.parsedTime?.startMin ?? 9999;
      return aStart.compareTo(bStart);
    });
  }

  // --- GOOGLE KEEP NOTES & CHECKLISTS ---
  List<String> get allKeepTags {
    final tags = <String>{};
    for (final note in _keepNotes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  void addKeepNote(KeepNoteModel note) {
    _keepNotes.insert(0, note);
    _save();
    notifyListeners();
  }

  void updateKeepNote(KeepNoteModel updated) {
    final index = _keepNotes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _keepNotes[index] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteKeepNote(String id) {
    final index = _keepNotes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final removed = _keepNotes.removeAt(index);
      _save();
      notifyListeners();

      showUndo('Deleted note "${removed.title.isEmpty ? "Note" : removed.title}"', () {
        _keepNotes.insert(index.clamp(0, _keepNotes.length), removed);
        _save();
        notifyListeners();
      });
    }
  }

  void toggleNotePin(String id) {
    final note = _keepNotes.firstWhere((n) => n.id == id, orElse: () => KeepNoteModel(id: ''));
    if (note.id.isNotEmpty) {
      note.isPinned = !note.isPinned;
      _save();
      notifyListeners();
    }
  }

  void toggleNoteArchive(String id) {
    final note = _keepNotes.firstWhere((n) => n.id == id, orElse: () => KeepNoteModel(id: ''));
    if (note.id.isNotEmpty) {
      note.isArchived = !note.isArchived;
      _save();
      notifyListeners();
    }
  }

  void toggleChecklistItem(String noteId, String itemId) {
    final note = _keepNotes.firstWhere((n) => n.id == noteId, orElse: () => KeepNoteModel(id: ''));
    final item = note.items.firstWhere((i) => i.id == itemId, orElse: () => ChecklistItem(id: '', text: ''));
    if (item.id.isNotEmpty) {
      item.done = !item.done;
      HapticFeedback.selectionClick();
      _save();
      notifyListeners();
    }
  }

  // --- SMART CONTEXT LINKING LAYER ---
  List<KeepNoteModel> getLinkedNotesForSlot(SlotModel slot, String dayName) {
    final result = <KeepNoteModel>[];
    final slotLabelLower = slot.label.toLowerCase();
    final dayLower = dayName.toLowerCase();

    for (final note in activeKeepNotes) {
      // 1. Explicit direct link
      if (note.linkedTaskLabels.any((l) => l.toLowerCase() == slotLabelLower) ||
          note.linkedDays.any((d) => d.toLowerCase() == dayLower)) {
        result.add(note);
        continue;
      }

      // 2. Smart tag & keyword matching
      final tagsLower = note.tags.map((t) => t.toLowerCase().replaceAll('#', '')).toList();
      final titleLower = note.title.toLowerCase();

      bool matches = false;
      if (slotLabelLower.contains('grocery') || slotLabelLower.contains('shopping')) {
        matches = tagsLower.contains('grocery') || tagsLower.contains('groceries') || tagsLower.contains('shopping') || titleLower.contains('grocery');
      } else if (slotLabelLower.contains('placement')) {
        matches = tagsLower.contains('placement') || tagsLower.contains('work') || titleLower.contains('placement');
      } else if (slotLabelLower.contains('study') || slotLabelLower.contains('coursework')) {
        matches = tagsLower.contains('study') || tagsLower.contains('exam') || tagsLower.contains('reading') || titleLower.contains('study');
      } else if (slotLabelLower.contains('crochet')) {
        matches = tagsLower.contains('crochet') || tagsLower.contains('craft') || titleLower.contains('crochet');
      } else if (slotLabelLower.contains('korean')) {
        matches = tagsLower.contains('korean') || tagsLower.contains('language') || titleLower.contains('korean');
      } else if (slotLabelLower.contains('church')) {
        matches = tagsLower.contains('church') || tagsLower.contains('sermon') || titleLower.contains('church');
      } else if (slotLabelLower.contains('scrabble')) {
        matches = tagsLower.contains('scrabble') || tagsLower.contains('game') || titleLower.contains('scrabble');
      } else if (slotLabelLower.contains('cleaning')) {
        matches = tagsLower.contains('cleaning') || tagsLower.contains('house') || tagsLower.contains('chores') || titleLower.contains('cleaning');
      }

      if (matches) {
        result.add(note);
      }
    }
    return result;
  }

  // --- SMART REMINDERS ---
  void addReminder(SmartReminderModel reminder) {
    _reminders.insert(0, reminder);
    NotificationService.scheduleReminderNotifications(reminder);
    _save();
    notifyListeners();
  }

  void deleteReminder(String id) {
    NotificationService.cancelReminderNotifications(id);
    _reminders.removeWhere((r) => r.id == id);
    _save();
    notifyListeners();
  }

  List<SmartReminderModel> get activeReminders => _reminders.where((r) => !r.isDismissed).toList();

  // --- CUSTOM TIMER & ALARM ---
  void setCustomTimerDuration(int seconds) {
    _customTimerDurationSeconds = seconds;
    notifyListeners();
  }

  void triggerAlarm() {
    _isAlarmRinging = true;
    AlarmSoundService.startAlarm();
    notifyListeners();
  }

  void stopAlarm() {
    _isAlarmRinging = false;
    AlarmSoundService.stopAlarm();
    notifyListeners();
  }

  void snoozeAlarm(int minutes) {
    stopAlarm();
    _customTimerDurationSeconds = minutes * 60;
    notifyListeners();
  }

  // --- MOOD & JOURNAL ---
  String? get currentMood => _moodLog[todayDateKey];

  void setTodayMood(String level) {
    _moodLog[todayDateKey] = level;
    _save();
    notifyListeners();
  }

  String getTodayJournalNote() {
    final entry = _journal[todayDateKey];
    if (entry is Map && entry['note'] != null) {
      return entry['note'].toString();
    }
    return '';
  }

  void setTodayJournalNote(String note) {
    final key = todayDateKey;
    final entry = Map<String, dynamic>.from(_journal[key] as Map? ?? {});
    if (note.trim().isEmpty) {
      entry.remove('note');
    } else {
      entry['note'] = note;
    }

    if (entry.isEmpty) {
      _journal.remove(key);
    } else {
      _journal[key] = entry;
    }
    _save();
    notifyListeners();
  }

  String getTaskJournalNote(String taskLabel) {
    final entry = _journal[todayDateKey];
    if (entry is Map && entry['tasks'] is Map) {
      final tasks = entry['tasks'] as Map;
      return tasks[taskLabel]?.toString() ?? '';
    }
    return '';
  }

  void setTaskJournalNote(String taskLabel, String note) {
    final key = todayDateKey;
    final entry = Map<String, dynamic>.from(_journal[key] as Map? ?? {});
    final tasks = Map<String, dynamic>.from(entry['tasks'] as Map? ?? {});

    if (note.trim().isEmpty) {
      tasks.remove(taskLabel);
    } else {
      tasks[taskLabel] = note;
    }

    if (tasks.isEmpty) {
      entry.remove('tasks');
    } else {
      entry['tasks'] = tasks;
    }

    if (entry.isEmpty) {
      _journal.remove(key);
    } else {
      _journal[key] = entry;
    }

    _save();
    notifyListeners();
  }

  // --- THEME ---
  void setTheme(String themeId, {Color? customAccent}) {
    _currentThemeId = themeId;
    if (customAccent != null) {
      _customAccent = customAccent;
    }
    _save();
    notifyListeners();
  }

  // --- UNDO SYSTEM ---
  void showUndo(String message, VoidCallback undoFn) {
    _undoTimer?.cancel();
    _currentUndo = UndoAction(message: message, undo: undoFn);
    notifyListeners();

    _undoTimer = Timer(const Duration(seconds: 6), () {
      _currentUndo = null;
      notifyListeners();
    });
  }

  void triggerUndo() {
    _currentUndo?.undo();
    _currentUndo = null;
    _undoTimer?.cancel();
    notifyListeners();
  }

  void dismissUndo() {
    _currentUndo = null;
    _undoTimer?.cancel();
    notifyListeners();
  }

  // --- WEEK ROLLOVER ---
  void _checkRollovers() {
    final nowKey = _getWeekKey();
    if (nowKey != _currentWeekKey && _currentWeekKey.isNotEmpty) {
      if (totalTasksThisWeek > 0) {
        _weekHistory.insert(
          0,
          WeekHistoryItem(
            weekOf: _currentWeekKey,
            doneTasks: doneTasksThisWeek,
            totalTasks: totalTasksThisWeek,
            fullDays: fullDaysThisWeek,
          ),
        );
        if (_weekHistory.length > 8) {
          _weekHistory = _weekHistory.sublist(0, 8);
        }

        // Record slot history
        for (final day in DefaultSchedule.days) {
          final slots = _schedule[day]?.slots ?? [];
          if (slots.isEmpty) continue;
          final dayPct = (_schedule[day]!.completionRatio * 100).round();
          _dayHistory[day] = [...(_dayHistory[day] ?? []), dayPct];
          if (_dayHistory[day]!.length > 8) {
            _dayHistory[day] = _dayHistory[day]!.sublist(_dayHistory[day]!.length - 8);
          }

          for (final s in slots) {
            final k = '$day|${s.label}';
            _slotHistory[k] = [...(_slotHistory[k] ?? []), s.done];
            if (_slotHistory[k]!.length > 8) {
              _slotHistory[k] = _slotHistory[k]!.sublist(_slotHistory[k]!.length - 8);
            }
          }
        }
      }

      // Reset all checkmarks for the new week
      for (final day in _schedule.values) {
        for (final s in day.slots) {
          s.done = false;
        }
      }

      _currentWeekKey = nowKey;
      _save();
    }
  }

  // --- STORAGE & PERSISTENCE ---
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _storage.loadData();
      if (data != null) {
        if (data['appTitle'] is String && (data['appTitle'] as String).isNotEmpty) {
          _appTitle = data['appTitle'].toString();
        }
        if (data['schedule'] is Map) {
          final schedMap = Map<String, dynamic>.from(data['schedule'] as Map);
          final loaded = <String, DayModel>{};
          for (final d in DefaultSchedule.days) {
            if (schedMap[d] is Map) {
              loaded[d] = DayModel.fromJson(d, Map<String, dynamic>.from(schedMap[d] as Map));
            } else {
              loaded[d] = DefaultSchedule.getDefaults()[d]!;
            }
          }
          _schedule = loaded;
        }
        if (data['keepNotes'] is List && (data['keepNotes'] as List).isNotEmpty) {
          _keepNotes = (data['keepNotes'] as List)
              .map((n) => KeepNoteModel.fromJson(Map<String, dynamic>.from(n as Map)))
              .toList();
        } else {
          _populateDefaultKeepNotes();
        }
        if (data['reminders'] is List) {
          _reminders = (data['reminders'] as List)
              .map((r) => SmartReminderModel.fromJson(Map<String, dynamic>.from(r as Map)))
              .toList();
        }
        _currentThemeId = data['theme']?.toString() ?? 'blush';
        if (data['customAccent'] is String) {
          _customAccent = AppColors.fromHex(data['customAccent']);
        }
        if (data['weekHistory'] is List) {
          _weekHistory = (data['weekHistory'] as List)
              .map((item) => WeekHistoryItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        if (data['slotHistory'] is Map) {
          _slotHistory = Map<String, dynamic>.from(data['slotHistory'] as Map).map(
            (k, v) => MapEntry(k, (v as List).map((b) => b as bool).toList()),
          );
        }
        if (data['dayHistory'] is Map) {
          _dayHistory = Map<String, dynamic>.from(data['dayHistory'] as Map).map(
            (k, v) => MapEntry(k, (v as List).map((n) => (n as num).toInt()).toList()),
          );
        }
        if (data['moodLog'] is Map) {
          _moodLog = Map<String, dynamic>.from(data['moodLog'] as Map).map(
            (k, v) => MapEntry(k, v.toString()),
          );
        }
        if (data['journal'] is Map) {
          _journal = Map<String, dynamic>.from(data['journal'] as Map);
        }
        if (data['dismissedInsights'] is Map) {
          _dismissedInsights = Map<String, dynamic>.from(data['dismissedInsights'] as Map).map(
            (k, v) => MapEntry(k, v.toString()),
          );
        }
        if (data['currentWeekKey'] is String) {
          _currentWeekKey = data['currentWeekKey'].toString();
        }
        if (data['biometricLock'] is bool) {
          _biometricLockEnabled = data['biometricLock'] as bool;
        }
        if (data['longestStreak'] is num) {
          _longestStreak = (data['longestStreak'] as num).toInt();
        }
        if (data['earnedBadges'] is List) {
          _earnedBadges = (data['earnedBadges'] as List).map((e) => e.toString()).toList();
        }
      } else {
        // First launch default notes
        _populateDefaultKeepNotes();
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    } finally {
      for (final day in _schedule.keys) {
        _sortDaySlots(day);
      }
      _checkRollovers();
      _updateWidget();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _populateDefaultKeepNotes() {
    _keepNotes = [
      KeepNoteModel(
        id: 'note_groceries_1',
        title: 'Weekly Grocery List',
        colorKey: 'sage',
        isPinned: true,
        tags: ['#groceries', '#weekly'],
        linkedTaskLabels: ['Grocery shopping'],
        linkedDays: ['Sunday'],
        items: [
          ChecklistItem(id: 'g1', text: 'Fresh almond milk', done: false),
          ChecklistItem(id: 'g2', text: 'Sourdough bread', done: false),
          ChecklistItem(id: 'g3', text: 'Avocados & spinach', done: true),
          ChecklistItem(id: 'g4', text: 'Greek yogurt & berries', done: false),
          ChecklistItem(id: 'g5', text: 'Coffee beans', done: true),
        ],
      ),
      KeepNoteModel(
        id: 'note_placement_1',
        title: 'Placement Shift Prep',
        colorKey: 'rose',
        isPinned: true,
        tags: ['#placement', '#prep'],
        linkedTaskLabels: ['Placement', 'Night shift'],
        content: 'Remember badge, notebook, water bottle, and electrolyte pack. Confirm shift handover checklist.',
      ),
      KeepNoteModel(
        id: 'note_study_1',
        title: 'Coursework Topics',
        colorKey: 'gold',
        tags: ['#study', '#notes'],
        linkedTaskLabels: ['Study time'],
        items: [
          ChecklistItem(id: 's1', text: 'Review Chapter 4 slides', done: true),
          ChecklistItem(id: 's2', text: 'Draft literature summary', done: false),
          ChecklistItem(id: 's3', text: 'Weekly practice questions', done: false),
        ],
      ),
      KeepNoteModel(
        id: 'note_crochet_1',
        title: 'Crochet Project Ideas',
        colorKey: 'lavender',
        tags: ['#crochet', '#crafts'],
        linkedTaskLabels: ['Crochet time'],
        content: 'Dusty rose yarn for granny square cardigan. Hook size 4.5mm. Pattern step 3 next.',
      ),
    ];
  }

  Future<void> _save() async {
    final payload = {
      'appTitle': _appTitle,
      'schedule': _schedule.map((k, v) => MapEntry(k, v.toJson())),
      'keepNotes': _keepNotes.map((n) => n.toJson()).toList(),
      'reminders': _reminders.map((r) => r.toJson()).toList(),
      'theme': _currentThemeId,
      'customAccent': _customAccent.value.toRadixString(16).padLeft(8, '0').substring(2),
      'weekHistory': _weekHistory.map((w) => w.toJson()).toList(),
      'slotHistory': _slotHistory,
      'dayHistory': _dayHistory,
      'moodLog': _moodLog,
      'journal': _journal,
      'dismissedInsights': _dismissedInsights,
      'currentWeekKey': _currentWeekKey,
      'biometricLock': _biometricLockEnabled,
      'longestStreak': _longestStreak,
      'earnedBadges': _earnedBadges,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _storage.saveData(payload);
    _updateWidget();
  }

  void _updateWidget() {
    final todayDay = _schedule[todayName];
    WidgetService.updateTodayWidget(
      appTitle: _appTitle,
      todayName: todayName,
      doneCount: todayDay?.doneCount ?? 0,
      totalCount: todayDay?.totalCount ?? 0,
      slots: todayDay?.slots ?? [],
    );
  }

  // Export / Import
  String exportJson() {
    final payload = {
      'appTitle': _appTitle,
      'schedule': _schedule.map((k, v) => MapEntry(k, v.toJson())),
      'keepNotes': _keepNotes.map((n) => n.toJson()).toList(),
      'reminders': _reminders.map((r) => r.toJson()).toList(),
      'theme': _currentThemeId,
      'customAccent': _customAccent.value.toRadixString(16).padLeft(8, '0').substring(2),
      'weekHistory': _weekHistory.map((w) => w.toJson()).toList(),
      'slotHistory': _slotHistory,
      'dayHistory': _dayHistory,
      'moodLog': _moodLog,
      'journal': _journal,
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<bool> importJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr);
      if (data is! Map) return false;
      await _storage.saveData(Map<String, dynamic>.from(data));
      await _loadFromStorage();
      return true;
    } catch (_) {
      return false;
    }
  }
}
