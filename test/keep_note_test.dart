import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keke_days_app/models/keep_note_model.dart';
import 'package:keke_days_app/models/smart_reminder_model.dart';
import 'package:keke_days_app/models/schedule_model.dart';
import 'package:keke_days_app/providers/schedule_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Keep Notes & Checklists Model Tests', () {
    test('KeepNoteModel serialization & checklist toggling', () {
      final note = KeepNoteModel(
        id: 'test_1',
        title: 'Weekly Groceries',
        colorKey: 'sage',
        isPinned: true,
        tags: ['#groceries', '#food'],
        linkedTaskLabels: ['Grocery shopping'],
        items: [
          ChecklistItem(id: '1', text: 'Almond Milk', done: false),
          ChecklistItem(id: '2', text: 'Avocados', done: true),
        ],
      );

      expect(note.isChecklist, isTrue);
      expect(note.doneItemCount, 1);
      expect(note.totalItemCount, 2);

      final json = note.toJson();
      final revived = KeepNoteModel.fromJson(json);

      expect(revived.id, 'test_1');
      expect(revived.title, 'Weekly Groceries');
      expect(revived.colorKey, 'sage');
      expect(revived.isPinned, isTrue);
      expect(revived.items.length, 2);
      expect(revived.items[1].done, isTrue);
      expect(revived.tags, contains('#groceries'));
    });
  });

  group('Smart Advance Reminder Model Tests', () {
    test('SmartReminderModel lead time urgency calculations', () {
      final now = DateTime.now();
      final reminderIn10Days = SmartReminderModel(
        id: 'r1',
        title: 'Placement Term',
        eventDate: now.add(const Duration(days: 10)),
      );

      final badge = reminderIn10Days.getUrgencyBadge(now);
      expect(badge, contains('Fortnight'));
    });
  });

  group('Smart Context Linking Tests', () {
    test('ScheduleProvider correctly associates notes with schedule slots', () async {
      final provider = ScheduleProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.addKeepNote(KeepNoteModel(
        id: 'test_groc',
        title: 'Sunday Shopping List',
        colorKey: 'sage',
        tags: ['#groceries'],
        items: [ChecklistItem(id: 'i1', text: 'Coffee', done: false)],
      ));

      final slot = SlotModel(time: '12:00 PM', label: 'Grocery shopping', desc: 'Buy food');
      final linked = provider.getLinkedNotesForSlot(slot, 'Sunday');

      expect(linked.isNotEmpty, isTrue);
      expect(linked.any((n) => n.title.contains('Shopping') || n.tags.contains('#groceries')), isTrue);
    });

    test('ScheduleProvider allows custom App Title', () async {
      final provider = ScheduleProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      provider.setAppTitle("Daniel's Rhythm");
      expect(provider.appTitle, "Daniel's Rhythm");
    });
  });
}
