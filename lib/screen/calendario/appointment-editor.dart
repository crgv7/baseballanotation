part of event_calendar;

class AppointmentEditor extends StatefulWidget {
  const AppointmentEditor({super.key});

  @override
  AppointmentEditorState createState() => AppointmentEditorState();
}

class AppointmentEditorState extends State<AppointmentEditor> {
  final DatabaseServices databaseServices = DatabaseServices.instance;

  Future<void> _saveEvent(Meeting meeting) async {
    try {
      final event = Event(
        id: meeting.id,
        eventName: meeting.eventName,
        from: meeting.from,
        to: meeting.to,
        notes: meeting.notes,
        isAllDay: meeting.isAllDay,
        colorIndex: _colorCollection.indexOf(meeting.background),
      );

      print('Guardando evento: ${event.eventName}'); // Debug
      print('Fecha inicio: ${event.from}'); // Debug
      print('Fecha fin: ${event.to}'); // Debug

      if (event.id == null) {
        await databaseServices.addEvent(event);
        print('Evento agregado exitosamente'); // Debug
      } else {
        await databaseServices.updateEvent(event);
        print('Evento actualizado exitosamente'); // Debug
      }

      // Navegar de vuelta a la pantalla principal después de guardar
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Error al guardar evento: $e'); // Debug
    }
  }

  // Lista de opciones y su estado (marcado o no)

/*
  void cambiarEstado(int index, bool nuevoValor) {
    setState(() {
      elementos[index].seleccionado = nuevoValor;
    });
  }
  */
  /// Returns a widget which will be used to edit the appointment details.
  ///
  /// The widget contains text fields to edit the subject, start and end date,
  /// time, and notes of the appointment. It also contains a switch to specify
  /// whether the appointment is all-day or not, and a color picker to select
  /// the color of the appointment.
  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            leading: const Text(''),
            title: TextField(
              controller: TextEditingController(text: _subject),
              onChanged: (String value) {
                _subject = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Add title',
              ),
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
          ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Icon(
                Icons.access_time,
                color: Colors.black54,
              ),
              title: Row(children: <Widget>[
                const Expanded(
                  child: Text('All-day'),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: _isAllDay,
                          onChanged: (bool value) {
                            setState(() {
                              _isAllDay = value;
                            });
                          },
                        ))),
              ])),
          ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: GestureDetector(
                          child: Text(
                              DateFormat('EEE, MMM dd yyyy').format(_startDate),
                              textAlign: TextAlign.left),
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (date != null && date != _startDate) {
                              setState(() {
                                final Duration difference =
                                    _endDate.difference(_startDate);
                                _startDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _startTime.hour,
                                    _startTime.minute,
                                    0);
                                _endDate = _startDate.add(difference);
                                _endTime = TimeOfDay(
                                    hour: _endDate.hour,
                                    minute: _endDate.minute);
                              });
                            }
                          }),
                    ),
                    Expanded(
                        flex: 3,
                        child: _isAllDay
                            ? const Text('')
                            : GestureDetector(
                                child: Text(
                                  DateFormat('hh:mm a').format(_startDate),
                                  textAlign: TextAlign.right,
                                ),
                                onTap: () async {
                                  final TimeOfDay? time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                          hour: _startTime.hour,
                                          minute: _startTime.minute));

                                  if (time != null && time != _startTime) {
                                    setState(() {
                                      _startTime = time;
                                      final Duration difference =
                                          _endDate.difference(_startDate);
                                      _startDate = DateTime(
                                          _startDate.year,
                                          _startDate.month,
                                          _startDate.day,
                                          _startTime.hour,
                                          _startTime.minute,
                                          0);
                                      _endDate = _startDate.add(difference);
                                      _endTime = TimeOfDay(
                                          hour: _endDate.hour,
                                          minute: _endDate.minute);
                                    });
                                  }
                                })),
                  ])),
          ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: GestureDetector(
                          child: Text(
                            DateFormat('EEE, MMM dd yyyy').format(_endDate),
                            textAlign: TextAlign.left,
                          ),
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (date != null && date != _endDate) {
                              setState(() {
                                final Duration difference =
                                    _endDate.difference(_startDate);
                                _endDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _endTime.hour,
                                    _endTime.minute,
                                    0);
                                if (_endDate.isBefore(_startDate)) {
                                  _startDate = _endDate.subtract(difference);
                                  _startTime = TimeOfDay(
                                      hour: _startDate.hour,
                                      minute: _startDate.minute);
                                }
                              });
                            }
                          }),
                    ),
                    Expanded(
                        flex: 3,
                        child: _isAllDay
                            ? const Text('')
                            : GestureDetector(
                                child: Text(
                                  DateFormat('hh:mm a').format(_endDate),
                                  textAlign: TextAlign.right,
                                ),
                                onTap: () async {
                                  final TimeOfDay? time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                          hour: _endTime.hour,
                                          minute: _endTime.minute));

                                  if (time != null && time != _endTime) {
                                    setState(() {
                                      _endTime = time;
                                      final Duration difference =
                                          _endDate.difference(_startDate);
                                      _endDate = DateTime(
                                          _endDate.year,
                                          _endDate.month,
                                          _endDate.day,
                                          _endTime.hour,
                                          _endTime.minute,
                                          0);
                                      if (_endDate.isBefore(_startDate)) {
                                        _startDate =
                                            _endDate.subtract(difference);
                                        _startTime = TimeOfDay(
                                            hour: _startDate.hour,
                                            minute: _startDate.minute);
                                      }
                                    });
                                  }
                                })),
                  ])),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Icon(
              Icons.public,
              color: Colors.black87,
            ),
            title: Text(_timeZoneCollection[_selectedTimeZoneIndex]),
            onTap: () {
              showDialog<Widget>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return _TimeZonePicker();
                },
              ).then((dynamic value) => setState(() {}));
            },
          ),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading:
                Icon(Icons.lens, color: _colorCollection[_selectedColorIndex]),
            title: Text(
              _colorNames[_selectedColorIndex],
            ),
            onTap: () {
              showDialog<Widget>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return _ColorPicker();
                },
              ).then((dynamic value) => setState(() {}));
            },
          ),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(5),
            leading: const Icon(
              Icons.subject,
              color: Colors.black87,
            ),
            title: TextField(
              controller: TextEditingController(text: _notes),
              onChanged: (String value) {
                _notes = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Add description',
              ),
            ),
          ),
          /*
                         Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selecciona opciones:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._options.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            return CheckboxListTile(
              title: Text(option),
              value: _selectedOptions[index],
              onChanged: (bool? value) {
                setState(() {
                  _selectedOptions[index] = value ?? false;
                });
              },
            );
          }).toList(),
            */

          const Divider(
            height: 1.0,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text(getTile()),
              backgroundColor: _colorCollection[_selectedColorIndex],
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    icon: const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final List<Meeting> meetings = <Meeting>[];
                      if (_selectedAppointment != null) {
                        _events.appointments!.removeAt(_events.appointments!
                            .indexOf(_selectedAppointment));
                        _events.notifyListeners(CalendarDataSourceAction.remove,
                            <Meeting>[]..add(_selectedAppointment!));
                      }
                      meetings.add(Meeting(
                        from: _startDate,
                        to: _endDate,
                        background: _colorCollection[_selectedColorIndex],
                        startTimeZone: _selectedTimeZoneIndex == 0
                            ? ''
                            : _timeZoneCollection[_selectedTimeZoneIndex],
                        endTimeZone: _selectedTimeZoneIndex == 0
                            ? ''
                            : _timeZoneCollection[_selectedTimeZoneIndex],
                        notes: _notes,
                        isAllDay: _isAllDay,
                        eventName: _subject == '' ? '(No title)' : _subject,
                        id: _selectedAppointment?.id,
                      ));

                      _events.appointments!.add(meetings[0]);
                      _saveEvent(meetings[0]); // Guardar en la base de datos

                      _events.notifyListeners(
                          CalendarDataSourceAction.add, meetings);
                      _selectedAppointment = null;

                      Navigator.pop(context);
                    })
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Stack(
                children: <Widget>[_getAppointmentEditor(context)],
              ),
            ),
            floatingActionButton: _selectedAppointment == null
                ? const Text('')
                : FloatingActionButton(
                    onPressed: () async {
                      if (_selectedAppointment != null) {
                        // Eliminar de la base de datos
                        final success = await DatabaseServices.instance
                            .deleteEvent(_selectedAppointment!.id!);
                        if (success) {
                          // Solo eliminar de la lista local si se eliminó correctamente de la base de datos
                          _events.appointments!.removeAt(_events.appointments!
                              .indexOf(_selectedAppointment));
                          _events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Meeting>[_selectedAppointment!]);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Evento eliminado correctamente')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error al eliminar el evento')),
                          );
                        }
                      }
                    },
                    child:
                        const Icon(Icons.delete_outline, color: Colors.white),
                    backgroundColor: Colors.red,
                  )));
  }

  String getTile() {
    return _subject.isEmpty ? 'New event' : 'Event details';
  }
}
