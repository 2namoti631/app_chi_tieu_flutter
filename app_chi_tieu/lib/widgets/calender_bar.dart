import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarPageBar extends StatefulWidget {
  final Function(DateTime) onDateSelected;  // thêm callback

  const CalendarPageBar({super.key, required this.onDateSelected});

  @override
  _CalendarPageBarState createState() => _CalendarPageBarState();
}

class _CalendarPageBarState extends State<CalendarPageBar> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'vi_VN',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDate,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDate, day);
      },
      calendarFormat: CalendarFormat.week,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      onDaySelected: (selected, focused) {
        setState(() {
          selectedDate = selected;
          focusedDate = focused;
        });
        widget.onDateSelected(selected);  // gọi callback để truyền ngày lên trên
      },
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}

