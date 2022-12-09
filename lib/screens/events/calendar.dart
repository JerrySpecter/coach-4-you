import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_factory/constants/colors.dart';
import 'package:health_factory/constants/global_state.dart';
import 'package:health_factory/constants/routes.dart';
import 'package:health_factory/widgets/home/hf_event_tile.dart';
import 'package:health_factory/widgets/hf_heading.dart';
import 'package:health_factory/widgets/hf_paragraph.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../constants/firebase_functions.dart';
import '../../utils/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List<Event>> _selectedEvents = {};
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
  }

  List<Event> getEventsfromDay(DateTime date) {
    return _selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var events = context.watch<HFGlobalState>().calendarEvents;

    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        TableCalendar(
          firstDay: DateTime.utc(2021, 1, 1),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(
                context.read<HFGlobalState>().calendarSelectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              context.read<HFGlobalState>().setCalendarSelectedDay(selectedDay);
              _focusedDay = focusedDay;
            });
          },
          availableCalendarFormats: const {
            CalendarFormat.week: 'Week',
            CalendarFormat.month: 'Month'
          },
          onFormatChanged: (format) {
            setState(() {
              _format = format;
            });
          },
          calendarFormat: _format,
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: (date) {
            return events[date] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) {
                return null;
              }

              return Container(
                padding: const EdgeInsets.only(
                  top: 4,
                  left: 4,
                  right: 4,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                  color: HFColors().pinkColor(),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  '${events.length}',
                  style: GoogleFonts.getFont(
                    'Manrope',
                    textStyle: TextStyle(
                      color: HFColors().secondaryColor(),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              );
            },
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: HFColors().primaryColor(),
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            selectedTextStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().secondaryColor(),
                fontSize: 14,
              ),
            ),
            todayTextStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().secondaryColor(),
                fontSize: 14,
              ),
            ),
            todayDecoration: BoxDecoration(
              color: HFColors().primaryColor(opacity: 0.5),
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            weekendDecoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            defaultDecoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            outsideDecoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            defaultTextStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().primaryColor(),
                fontSize: 14,
              ),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().primaryColor(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            weekendStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().primaryColor(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            leftChevronPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 0,
            ),
            formatButtonDecoration: BoxDecoration(
              color: HFColors().primaryColor(),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            formatButtonTextStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().secondaryColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 1.1,
              ),
            ),
            rightChevronPadding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 0,
            ),
            leftChevronMargin: const EdgeInsets.symmetric(horizontal: 0),
            rightChevronMargin: const EdgeInsets.symmetric(horizontal: 0),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: HFColors().primaryColor(),
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: HFColors().primaryColor(),
            ),
            titleTextStyle: GoogleFonts.getFont(
              'Manrope',
              textStyle: TextStyle(
                color: HFColors().primaryColor(),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (events[context.watch<HFGlobalState>().calendarSelectedDay] ==
                null ||
            events[context.watch<HFGlobalState>().calendarSelectedDay]!.isEmpty)
          const HFParagrpah(
            text: 'No workouts for this day.',
            size: 10,
          )
        else
          Expanded(
            child: ListView(
              children: [
                ...events[context.watch<HFGlobalState>().calendarSelectedDay]!
                    .map(
                  (event) {
                    return HFEventTile(
                      title: event.title,
                      startTime: event.startTime,
                      endTime: event.endTime,
                      color: event.color,
                      client: event.client,
                      location: event.location,
                      isDone: event.isDone,
                      useSpacerBottom: true,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          eventRoute,
                          arguments: event,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
      ],
    ));
  }
}
