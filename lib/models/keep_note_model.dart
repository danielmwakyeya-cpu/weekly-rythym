import 'dart:convert';
import 'package:flutter/material.dart';

class ChecklistItem {
  final String id;
  String text;
  bool done;

  ChecklistItem({
    required this.id,
    required this.text,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'done': done,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String? ?? UniqueKey().toString(),
        text: json['text'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );

  ChecklistItem copyWith({String? text, bool? done}) => ChecklistItem(
        id: id,
        text: text ?? this.text,
        done: done ?? this.done,
      );
}

class NoteColorOption {
  final String key;
  final String name;
  final Color bg;
  final Color border;

  const NoteColorOption({
    required this.key,
    required this.name,
    required this.bg,
    required this.border,
  });
}

class NoteColors {
  static const List<NoteColorOption> options = [
    NoteColorOption(
      key: 'default',
      name: 'Default',
      bg: Color(0xFF351C29),
      border: Color(0xFF5A2E46),
    ),
    NoteColorOption(
      key: 'rose',
      name: 'Rose',
      bg: Color(0xFF421E2E),
      border: Color(0xFF8A3B60),
    ),
    NoteColorOption(
      key: 'terracotta',
      name: 'Terracotta',
      bg: Color(0xFF3D211B),
      border: Color(0xFF8A4637),
    ),
    NoteColorOption(
      key: 'sage',
      name: 'Sage',
      bg: Color(0xFF1E2E24),
      border: Color(0xFF3F634E),
    ),
    NoteColorOption(
      key: 'gold',
      name: 'Gold',
      bg: Color(0xFF382915),
      border: Color(0xFF7A5826),
    ),
    NoteColorOption(
      key: 'lavender',
      name: 'Lavender',
      bg: Color(0xFF261D3B),
      border: Color(0xFF533F7D),
    ),
    NoteColorOption(
      key: 'slate',
      name: 'Slate',
      bg: Color(0xFF1F2433),
      border: Color(0xFF3D4766),
    ),
  ];

  static NoteColorOption get(String? key) {
    return options.firstWhere((o) => o.key == key, orElse: () => options[0]);
  }
}

class KeepNoteModel {
  final String id;
  String title;
  String content;
  String colorKey;
  bool isPinned;
  bool isArchived;
  List<ChecklistItem> items;
  List<String> tags;
  List<String> linkedTaskLabels;
  List<String> linkedDays;
  DateTime createdAt;
  DateTime updatedAt;

  KeepNoteModel({
    required this.id,
    this.title = '',
    this.content = '',
    this.colorKey = 'default',
    this.isPinned = false,
    this.isArchived = false,
    List<ChecklistItem>? items,
    List<String>? tags,
    List<String>? linkedTaskLabels,
    List<String>? linkedDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : items = items ?? [],
        tags = tags ?? [],
        linkedTaskLabels = linkedTaskLabels ?? [],
        linkedDays = linkedDays ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isChecklist => items.isNotEmpty;
  int get doneItemCount => items.where((i) => i.done).length;
  int get totalItemCount => items.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'colorKey': colorKey,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'items': items.map((i) => i.toJson()).toList(),
        'tags': tags,
        'linkedTaskLabels': linkedTaskLabels,
        'linkedDays': linkedDays,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory KeepNoteModel.fromJson(Map<String, dynamic> json) => KeepNoteModel(
        id: json['id'] as String? ?? UniqueKey().toString(),
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        colorKey: json['colorKey'] as String? ?? 'default',
        isPinned: json['isPinned'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => ChecklistItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        tags: (json['tags'] as List<dynamic>? ?? []).map((t) => t.toString()).toList(),
        linkedTaskLabels: (json['linkedTaskLabels'] as List<dynamic>? ?? []).map((t) => t.toString()).toList(),
        linkedDays: (json['linkedDays'] as List<dynamic>? ?? []).map((d) => d.toString()).toList(),
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      );

  KeepNoteModel copyWith({
    String? title,
    String? content,
    String? colorKey,
    bool? isPinned,
    bool? isArchived,
    List<ChecklistItem>? items,
    List<String>? tags,
    List<String>? linkedTaskLabels,
    List<String>? linkedDays,
  }) =>
      KeepNoteModel(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        colorKey: colorKey ?? this.colorKey,
        isPinned: isPinned ?? this.isPinned,
        isArchived: isArchived ?? this.isArchived,
        items: items ?? this.items.map((i) => i.copyWith()).toList(),
        tags: tags ?? List<String>.from(this.tags),
        linkedTaskLabels: linkedTaskLabels ?? List<String>.from(this.linkedTaskLabels),
        linkedDays: linkedDays ?? List<String>.from(this.linkedDays),
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
