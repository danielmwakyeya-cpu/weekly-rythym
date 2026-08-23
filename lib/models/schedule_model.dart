import 'dart:convert';

enum SlotKind {
  normal,
  fixed,
  night;

  String get displayName {
    switch (this) {
      case SlotKind.fixed:
        return 'set time';
      case SlotKind.night:
        return 'overnight';
      case SlotKind.normal:
        return 'flexible';
    }
  }

  static SlotKind fromString(String? val) {
    if (val == 'fixed') return SlotKind.fixed;
    if (val == 'night') return SlotKind.night;
    return SlotKind.normal;
  }

  String toJson() {
    switch (this) {
      case SlotKind.fixed:
        return 'fixed';
      case SlotKind.night:
        return 'night';
      case SlotKind.normal:
        return 'normal';
    }
  }
}

class ParsedTime {
  final int? startMin;
  final int? endMin;
  final bool crossesMidnight;

  const ParsedTime({
    this.startMin,
    this.endMin,
    this.crossesMidnight = false,
  });

  static int? parseClock(String token) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false).firstMatch(token);
    if (match == null) return null;
    int h = int.parse(match.group(1)!);
    final min = int.parse(match.group(2)!);
    final ampm = match.group(3)!.toUpperCase();
    if (ampm == 'PM' && h != 12) h += 12;
    if (ampm == 'AM' && h == 12) h = 0;
    return h * 60 + min;
  }

  static String sanitizeStr(String str) {
    return str
        .replaceAll(RegExp(r'\u00E2\u20AC[\u201C\u201D\u2013\u2014\u0153\u02dc]|\u00E2\u20AC\u201C|\u00E2\u20AC\u201D|\u00E2\u20AC\u2013|\u00E2\u20AC\u2014|\u00E2\u20AC\u0153|\u00E2\u20AC\u02dc|\u00E2\u0153\u201C|\u00E2\u20AC\u2122'), ' \u2013 ')
        .replaceAll(RegExp(r'[\u2013\u2014]'), ' \u2013 ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' - ', ' \u2013 ')
        .trim();
  }

  static ParsedTime? parse(String rawStr) {
    final timeStr = sanitizeStr(rawStr);
    final parts = timeStr.split(RegExp(r'[\u2013\u2014\-]')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final endMin = parts.length > 1 ? parseClock(parts[1]) : null;
    int? startMin = parseClock(parts[0]);

    if (startMin == null && parts.isNotEmpty) {
      final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(parts[0]);
      if (m != null) {
        final h = int.parse(m.group(1)!);
        final min = int.parse(m.group(2)!);
        final endIsPM = parts.length > 1 && parts[1].toUpperCase().contains('PM');
        int to24(int hour, bool pm) => (pm && hour != 12) ? hour + 12 : (!pm && hour == 12 ? 0 : hour);
        int candidate = to24(h, endIsPM) * 60 + min;
        if (endMin != null && candidate > endMin) {
          candidate = to24(h, !endIsPM) * 60 + min;
        }
        startMin = candidate;
      }
    }

    if (startMin == null) return null;
    final crosses = endMin != null && endMin <= startMin;
    return ParsedTime(startMin: startMin, endMin: endMin, crossesMidnight: crosses);
  }

  static String formatClock(int min) {
    min = ((min % (24 * 60)) + 24 * 60) % (24 * 60);
    final h = min ~/ 60;
    final m = min % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    int h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:${m.toString().padLeft(2, '0')} $ampm';
  }

  static String formatRange(int startMin, int? endMin) {
    if (endMin == null) return formatClock(startMin);
    return '${formatClock(startMin)} \u2013 ${formatClock(endMin)}';
  }
}

class SlotModel {
  String _time;
  String _label;
  String _desc;
  SlotKind kind;
  bool done;
  ParsedTime? _parsedTime;

  SlotModel({
    required String time,
    required String label,
    required String desc,
    this.kind = SlotKind.normal,
    this.done = false,
  })  : _time = ParsedTime.sanitizeStr(time),
        _label = ParsedTime.sanitizeStr(label),
        _desc = ParsedTime.sanitizeStr(desc) {
    _parsedTime = ParsedTime.parse(_time);
  }

  String get time => ParsedTime.sanitizeStr(_time);
  set time(String val) {
    _time = ParsedTime.sanitizeStr(val);
    _parsedTime = ParsedTime.parse(_time);
  }

  String get label => ParsedTime.sanitizeStr(_label);
  set label(String val) => _label = ParsedTime.sanitizeStr(val);

  String get desc => ParsedTime.sanitizeStr(_desc);
  set desc(String val) => _desc = ParsedTime.sanitizeStr(val);

  ParsedTime? get parsedTime => _parsedTime ??= ParsedTime.parse(_time);

  void updateTime(String newTime) {
    time = newTime;
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'label': label,
        'desc': desc,
        'kind': kind.toJson(),
        'done': done,
      };

  factory SlotModel.fromJson(Map<String, dynamic> json) => SlotModel(
        time: json['time'] as String? ?? '12:00 PM',
        label: json['label'] as String? ?? 'Task',
        desc: json['desc'] as String? ?? '',
        kind: SlotKind.fromString(json['kind'] as String?),
        done: json['done'] as bool? ?? false,
      );

  SlotModel copyWith({
    String? time,
    String? label,
    String? desc,
    SlotKind? kind,
    bool? done,
  }) =>
      SlotModel(
        time: time ?? this.time,
        label: label ?? this.label,
        desc: desc ?? this.desc,
        kind: kind ?? this.kind,
        done: done ?? this.done,
      );
}

class DayModel {
  final String dayName;
  String _note;
  List<SlotModel> slots;

  DayModel({
    required this.dayName,
    required String note,
    required this.slots,
  }) : _note = ParsedTime.sanitizeStr(note);

  String get note => ParsedTime.sanitizeStr(_note);
  set note(String val) => _note = ParsedTime.sanitizeStr(val);

  Map<String, dynamic> toJson() => {
        'note': note,
        'slots': slots.map((s) => s.toJson()).toList(),
      };

  factory DayModel.fromJson(String dayName, Map<String, dynamic> json) => DayModel(
        dayName: dayName,
        note: json['note'] as String? ?? '',
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((s) => SlotModel.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
      );

  DayModel copyWith({
    String? note,
    List<SlotModel>? slots,
  }) =>
      DayModel(
        dayName: dayName,
        note: note ?? this.note,
        slots: slots ?? this.slots.map((s) => s.copyWith()).toList(),
      );

  int get totalCount => slots.length;
  int get doneCount => slots.where((s) => s.done).length;
  double get completionRatio => totalCount == 0 ? 0.0 : doneCount / totalCount;
  int get completionPercent => (completionRatio * 100).round();
  bool get isFullyDone => totalCount > 0 && doneCount == totalCount;
}

class WeekHistoryItem {
  final String weekOf;
  final int doneTasks;
  final int totalTasks;
  final int fullDays;

  WeekHistoryItem({
    required this.weekOf,
    required this.doneTasks,
    required this.totalTasks,
    required this.fullDays,
  });

  int get percent => totalTasks == 0 ? 0 : ((doneTasks / totalTasks) * 100).round();

  Map<String, dynamic> toJson() => {
        'weekOf': weekOf,
        'doneTasks': doneTasks,
        'totalTasks': totalTasks,
        'fullDays': fullDays,
      };

  factory WeekHistoryItem.fromJson(Map<String, dynamic> json) => WeekHistoryItem(
        weekOf: json['weekOf'] as String? ?? '',
        doneTasks: (json['doneTasks'] as num?)?.toInt() ?? 0,
        totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
        fullDays: (json['fullDays'] as num?)?.toInt() ?? 0,
      );
}
