library event_calendar;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:baseballScore/models/event.dart';
import 'package:baseballScore/services/database_services.dart';

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
      appointments = events
          .map((event) => Meeting(
                eventName: event.eventName,
                from: event.from,
                to: event.to,
                background: _colorCollection[event.colorIndex],
                isAllDay: event.isAllDay,
                id: event.id,
                notes: event.notes ?? '',
              ))
          .toList();
      _events = DataSource(appointments);
    });
  }

  Future<void> _saveEvent(Meeting meeting) async {
    try {
      print('Preparando evento para guardar: ${meeting.eventName}');
      final event = Event(
        id: meeting.id,
        eventName: meeting.eventName,
        from: meeting.from,
        to: meeting.to,
        notes: meeting.notes,
        isAllDay: meeting.isAllDay,
        colorIndex: _colorCollection.indexOf(meeting.background),
      );

      print('Guardando evento en la base de datos...');
      if (event.id == null) {
        print('Creando nuevo evento');
        final id = await databaseServices.addEvent(event);
        print('Nuevo evento creado con ID: $id');
      } else {
        print('Actualizando evento existente');
        await databaseServices.updateEvent(event);
        print('Evento actualizado exitosamente');
      }

      print('Recargando eventos...');
      await _loadEvents();
      print('Eventos recargados exitosamente');
    } catch (e) {
      print('Error al guardar evento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(Meeting meeting) async {
    try {
      print('🔍 INICIO Proceso de eliminación de evento');
      print('🔑 ID del evento: ${meeting.id}');

      if (meeting.id == null) {
        print('❌ ERROR: El ID del evento es NULL');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede eliminar un evento sin ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Log detalles del evento antes de borrar
      print('📋 Detalles del evento:');
      print('   Nombre: ${meeting.eventName}');
      print('   Fecha inicio: ${meeting.from}');
      print('   Fecha fin: ${meeting.to}');

      // Imprimir todos los eventos actuales antes de borrar
      print('📊 Estado de eventos ANTES del borrado:');
      for (var event in appointments) {
        print('   ID: ${event.id}, Nombre: ${event.eventName}');
      }

      // Intentar borrar el evento
      final bool success = await databaseServices.deleteEvent(meeting.id!);

      print('✅ Resultado de borrado en base de datos: $success');

      if (success) {
        // Recargar eventos después del borrado
        await _loadEvents();

        // Imprimir eventos después de recargar
        print('📊 Estado de eventos DESPUÉS del borrado:');
        for (var event in appointments) {
          print('   ID: ${event.id}, Nombre: ${event.eventName}');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ No se pudo borrar el evento de la base de datos');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo eliminar el evento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      print('🔚 FIN Proceso de eliminación de evento');
    } catch (e, stackTrace) {
      print('❌ ERROR CRÍTICO al eliminar evento:');
      print('Excepción: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error crítico al eliminar el evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  SfCalendar getEventCalendar(CalendarDataSource _calendarDataSource,
      CalendarTapCallback calendarTapCallback) {
    return SfCalendar(
        view: CalendarView.month,
        controller: calendarController,
        allowedViews: const [
          CalendarView.week,
          CalendarView.timelineWeek,
          CalendarView.month
        ],
        dataSource: _calendarDataSource,
        onTap: calendarTapCallback,
        appointmentBuilder: (context, calendarAppointmentDetails) {
          final Meeting meeting = calendarAppointmentDetails.appointments.first;
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
