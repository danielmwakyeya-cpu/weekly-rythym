class SmartReminderModel {
  final String id;
  String title;
  DateTime eventDate;
  String? dayName;
  String? taskLabel;
  String customNote;
  bool isMonthActive;
  bool isFortnightActive;
  bool isWeekActive;
  bool isDayActive;
  bool isAtTimeActive;
  bool isDismissed;

  SmartReminderModel({
    required this.id,
    required this.title,
    required this.eventDate,
    this.dayName,
    this.taskLabel,
    this.customNote = '',
    this.isMonthActive = true,
    this.isFortnightActive = true,
    this.isWeekActive = true,
    this.isDayActive = true,
    this.isAtTimeActive = true,
    this.isDismissed = false,
  });

  String getUrgencyBadge(DateTime now) {
    final diff = eventDate.difference(now);
    final days = diff.inDays;

    if (diff.isNegative) return 'Completed';
    if (days == 0) return 'Today!';
    if (days == 1) return 'Tomorrow';
    if (days <= 7) return 'in $days days (1 wk)';
    if (days <= 14) return 'in ${(days / 7).ceil()} wks (Fortnight)';
    if (days <= 31) return 'in ${(days / 7).ceil()} wks (1 Month)';
    return 'in ${(days / 30).ceil()} months';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'eventDate': eventDate.toIso8601String(),
        'dayName': dayName,
        'taskLabel': taskLabel,
        'customNote': customNote,
        'isMonthActive': isMonthActive,
        'isFortnightActive': isFortnightActive,
        'isWeekActive': isWeekActive,
        'isDayActive': isDayActive,
        'isAtTimeActive': isAtTimeActive,
        'isDismissed': isDismissed,
      };

  factory SmartReminderModel.fromJson(Map<String, dynamic> json) => SmartReminderModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Reminder',
        eventDate: DateTime.tryParse(json['eventDate']?.toString() ?? '') ?? DateTime.now(),
        dayName: json['dayName'] as String?,
        taskLabel: json['taskLabel'] as String?,
        customNote: json['customNote'] as String? ?? '',
        isMonthActive: json['isMonthActive'] as bool? ?? true,
        isFortnightActive: json['isFortnightActive'] as bool? ?? true,
        isWeekActive: json['isWeekActive'] as bool? ?? true,
        isDayActive: json['isDayActive'] as bool? ?? true,
        isAtTimeActive: json['isAtTimeActive'] as bool? ?? true,
        isDismissed: json['isDismissed'] as bool? ?? false,
      );
}
