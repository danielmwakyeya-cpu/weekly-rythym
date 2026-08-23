import '../models/schedule_model.dart';

class DefaultSchedule {
  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static Map<String, DayModel> getDefaults() {
    return {
      'Monday': DayModel(
        dayName: 'Monday',
        note: 'Placement day',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '8:15 \u2013 8:45 AM', label: 'Morning routine', desc: 'Get ready for placement', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 5:00 PM', label: 'Placement', desc: 'At placement', kind: SlotKind.fixed),
          SlotModel(time: '5:30 \u2013 6:30 PM', label: 'Doom scroll time', desc: 'Decompress, guilt-free scrolling', kind: SlotKind.normal),
          SlotModel(time: '6:30 \u2013 7:30 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
          SlotModel(time: '7:45 \u2013 8:45 PM', label: 'Study time', desc: 'Coursework and focused reading', kind: SlotKind.normal),
        ],
      ),
      'Tuesday': DayModel(
        dayName: 'Tuesday',
        note: 'Placement by day, Korean class in the evening',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '8:15 \u2013 8:45 AM', label: 'Morning routine', desc: 'Get ready for placement', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 5:00 PM', label: 'Placement', desc: 'At placement', kind: SlotKind.fixed),
          SlotModel(time: '6:00 \u2013 7:30 PM', label: 'Korean class', desc: 'Language practice', kind: SlotKind.fixed),
          SlotModel(time: '7:45 \u2013 8:30 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
          SlotModel(time: '8:30 \u2013 9:15 PM', label: 'Doom scroll time', desc: 'Decompress before bed', kind: SlotKind.normal),
        ],
      ),
      'Wednesday': DayModel(
        dayName: 'Wednesday',
        note: 'Placement by day, night shift overnight \u2014 a long one',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '8:15 \u2013 8:45 AM', label: 'Morning routine', desc: 'Get ready for placement', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 5:00 PM', label: 'Placement', desc: 'At placement', kind: SlotKind.fixed),
          SlotModel(time: '5:30 \u2013 6:30 PM', label: 'Dinner & doom scroll', desc: 'Eat and decompress', kind: SlotKind.normal),
          SlotModel(time: '6:30 \u2013 8:30 PM', label: 'Rest / nap', desc: 'Bank some sleep before the shift', kind: SlotKind.normal),
          SlotModel(time: '8:30 \u2013 9:00 PM', label: 'Get ready', desc: 'Fuel up before heading out', kind: SlotKind.normal),
          SlotModel(time: '9:00 PM \u2013 5:00 AM', label: 'Night shift', desc: 'At work overnight', kind: SlotKind.night),
        ],
      ),
      'Thursday': DayModel(
        dayName: 'Thursday',
        note: 'Placement day',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '8:15 \u2013 8:45 AM', label: 'Morning routine', desc: 'Get ready for placement', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 5:00 PM', label: 'Placement', desc: 'At placement', kind: SlotKind.fixed),
          SlotModel(time: '5:30 \u2013 6:30 PM', label: 'Doom scroll time', desc: 'Decompress, guilt-free scrolling', kind: SlotKind.normal),
          SlotModel(time: '6:30 \u2013 7:30 PM', label: 'Study time', desc: 'Coursework and focused reading', kind: SlotKind.normal),
          SlotModel(time: '7:45 \u2013 8:45 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
        ],
      ),
      'Friday': DayModel(
        dayName: 'Friday',
        note: 'Last placement day of the week',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '8:15 \u2013 8:45 AM', label: 'Morning routine', desc: 'Get ready for placement', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 5:00 PM', label: 'Placement', desc: 'At placement', kind: SlotKind.fixed),
          SlotModel(time: '5:30 \u2013 6:30 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
          SlotModel(time: '6:30 \u2013 7:30 PM', label: 'Study time', desc: 'Coursework and focused reading', kind: SlotKind.normal),
          SlotModel(time: '7:45 \u2013 8:30 PM', label: 'Doom scroll time', desc: 'Decompress into the weekend', kind: SlotKind.normal),
        ],
      ),
      'Saturday': DayModel(
        dayName: 'Saturday',
        note: 'Cleaning job in the morning, Scrabble after',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '9:00 AM \u2013 12:00 PM', label: 'House cleaning job', desc: 'Work block', kind: SlotKind.fixed),
          SlotModel(time: '12:30 \u2013 1:00 PM', label: 'Lunch', desc: 'Refuel before Scrabble', kind: SlotKind.normal),
          SlotModel(time: '1:00 \u2013 4:00 PM', label: 'Scrabble', desc: 'Game time', kind: SlotKind.fixed),
          SlotModel(time: '4:30 \u2013 5:30 PM', label: 'Doom scroll time', desc: 'Guilt-free scrolling, timer optional', kind: SlotKind.normal),
          SlotModel(time: 'Evening', label: 'Free time', desc: 'Relax into Sunday', kind: SlotKind.normal),
        ],
      ),
      'Sunday': DayModel(
        dayName: 'Sunday',
        note: 'Church in the morning, groceries after',
        slots: [
          SlotModel(time: '8:00 AM', label: 'Wake up', desc: 'Rise and greet the day', kind: SlotKind.normal),
          SlotModel(time: '9:00 \u2013 11:00 AM', label: 'Church', desc: 'Morning service', kind: SlotKind.fixed),
          SlotModel(time: '12:00 \u2013 2:00 PM', label: 'Grocery shopping', desc: 'Stock up for the week', kind: SlotKind.fixed),
          SlotModel(time: '2:30 \u2013 3:30 PM', label: 'Crochet time', desc: 'Hands busy, mind quiet', kind: SlotKind.normal),
          SlotModel(time: '4:00 \u2013 5:00 PM', label: 'Doom scroll time', desc: 'Guilt-free scrolling, timer optional', kind: SlotKind.normal),
          SlotModel(time: 'Evening', label: 'Study time', desc: 'Light review to set up the week ahead', kind: SlotKind.normal),
        ],
      ),
    };
  }

  static String tagFor(String day) {
    switch (day) {
      case 'Wednesday':
        return 'placement + night';
      case 'Tuesday':
        return 'Korean 6pm';
      case 'Monday':
      case 'Thursday':
      case 'Friday':
        return 'placement';
      case 'Saturday':
        return 'cleaning + Scrabble';
      case 'Sunday':
        return 'church';
      default:
        return '';
    }
  }

  static String moonPhaseFor(String day) {
    switch (day) {
      case 'Monday':
        return 'waxing-crescent';
      case 'Tuesday':
        return 'first-quarter';
      case 'Wednesday':
        return 'waxing-gibbous';
      case 'Thursday':
        return 'full';
      case 'Friday':
        return 'waning-gibbous';
      case 'Saturday':
        return 'last-quarter';
      case 'Sunday':
        return 'waning-crescent';
      default:
        return 'full';
    }
  }
}
