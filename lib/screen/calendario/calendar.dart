library event_calendar;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:baseballanotation/models/event.dart';
import 'package:baseballanotation/services/database_services.dart';

part 'color-picker.dart';

part 'timezone-picker.dart';

part 'appointment-editor.dart';

//ignore: must_be_immutable
class EventCalendar extends StatefulWidget {
  const EventCalendar({Key? key}) : super(key: key);

  @override
  EventCalendarState createState() => EventCalendarState();
}

List<Color> _colorCollection = <Color>[
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.cyan,
  Colors.brown,
  Colors.indigo,
];

List<String> _colorNames = <String>[
  'Blue',
  'Green',
  'Red',
  'Purple',
  'Orange',
  'Teal',
  'Pink',
  'Cyan',
  'Brown',
  'Indigo',
];

int _selectedColorIndex = 0;
int _selectedTimeZoneIndex = 0;
List<String> _timeZoneCollection = <String>[
  'Default Time',
  'AUS Central Standard Time',
  'AUS Eastern Standard Time',
  'Afghanistan Standard Time',
  'America Standard Time',
  'Arab Standard Time',
  'Arabian Standard Time',
];

List<String> eventNameCollection = <String>[
  'Conference',
  'Consulting',
  'Business',
  'Meeting',
  'Training',
  'Scrum',
  'Project Review',
  'Client Meeting',
  'Status Update',
  'Testing',
];

late DataSource _events;
Meeting? _selectedAppointment;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
bool _isAllDay = false;
String _subject = '';
String _notes = '';

class EventCalendarState extends State<EventCalendar> {
  EventCalendarState();
  CalendarController calendarController = CalendarController();
  final DatabaseServices databaseServices = DatabaseServices.instance;
  List<Meeting> appointments = [];

  @override
  void initState() {
    super.initState();
    _events = DataSource(appointments);
    _loadEvents();
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';
  }

  Future<void> _loadEvents() async {
    final events = await databaseServices.getEvents();
    setState(() {
      appointments = events.map((event) => Meeting(
        eventName: event.eventName,
        from: event.from,
        to: event.to,
        background: _colorCollection[event.colorIndex],
        isAllDay: event.isAllDay,
        id: event.id,
        notes: event.notes ?? '',
      )).toList();
      _events = DataSource(appointments);
    });
  }

  Future<void> _saveEvent(Meeting meeting) async {
    final event = Event(
      id: meeting.id,
      eventName: meeting.eventName,
      from: meeting.from,
      to: meeting.to,
      notes: meeting.notes,
      isAllDay: meeting.isAllDay,
      colorIndex: _colorCollection.indexOf(meeting.background),
    );

    if (event.id == null) {
      await databaseServices.addEvent(event);
    } else {
      await databaseServices.updateEvent(event);
    }
    _loadEvents();
  }

  Future<void> _deleteEvent(Meeting meeting) async {
    if (meeting.id != null) {
      await databaseServices.deleteEvent(meeting.id!);
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: getEventCalendar(_events, onCalendarTapped)));
  }

  SfCalendar getEventCalendar(
      CalendarDataSource _calendarDataSource,
      CalendarTapCallback calendarTapCallback) {
    return SfCalendar(
        view: CalendarView.month,
        controller: calendarController,
        allowedViews: const [CalendarView.week, CalendarView.timelineWeek, CalendarView.month],
        dataSource: _calendarDataSource,
        onTap: calendarTapCallback,
        appointmentBuilder: (context, calendarAppointmentDetails) {
          final Meeting meeting =
              calendarAppointmentDetails.appointments.first;
          return Container(
            color: meeting.background.withOpacity(0.8),
            child: Text(meeting.eventName),
          );
        },
        initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 0, 0, 0),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        timeSlotViewSettings: const TimeSlotViewSettings(
            minimumAppointmentDuration: Duration(minutes: 60)));
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement != CalendarElement.calendarCell &&
        calendarTapDetails.targetElement != CalendarElement.appointment) {
      return;
    }

    setState(() {
      _selectedAppointment = null;
      _isAllDay = false;
      _selectedColorIndex = 0;
      _selectedTimeZoneIndex = 0;
      _subject = '';
      _notes = '';
      if (calendarController.view == CalendarView.month) {
        calendarController.view = CalendarView.day;
      } else {
        if (calendarTapDetails.appointments != null &&
            calendarTapDetails.appointments!.length == 1) {
          final Meeting meetingDetails = calendarTapDetails.appointments![0];
          _startDate = meetingDetails.from;
          _endDate = meetingDetails.to;
          _isAllDay = meetingDetails.isAllDay;
          _selectedColorIndex =
              _colorCollection.indexOf(meetingDetails.background);
          _selectedTimeZoneIndex = meetingDetails.startTimeZone == ''
              ? 0
              : _timeZoneCollection.indexOf(meetingDetails.startTimeZone);
          _subject = meetingDetails.eventName == '(No title)'
              ? ''
              : meetingDetails.eventName;
          _notes = meetingDetails.notes;
          _selectedAppointment = meetingDetails;
        } else {
          final DateTime date = calendarTapDetails.date!;
          _startDate = date;
          _endDate = date.add(const Duration(hours: 1));
        }
        _startTime =
            TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
        _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AppointmentEditor()),
        );
      }
    });
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  String getStartTimeZone(int index) => appointments![index].startTimeZone;

  @override
  String getNotes(int index) => appointments![index].notes;

  @override
  String getEndTimeZone(int index) => appointments![index].endTimeZone;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;
}

class Meeting {
  Meeting(
      {required this.from,
      required this.to,
      this.background = Colors.green,
      this.isAllDay = false,
      this.eventName = '',
      this.startTimeZone = '',
      this.endTimeZone = '',
      this.notes = '',
      this.id});

  final String eventName;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;
  final String startTimeZone;
  final String endTimeZone;
  final String notes;
  final int? id;
}
