import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../models/medication_schedule.dart';

class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() =>
      _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends ConsumerState<ScheduleCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
  }

  List<MedicationSchedule> _getSchedulesForDay(
    DateTime day,
    List<MedicationSchedule> schedules,
  ) {
    return schedules.where((schedule) => schedule.isScheduledForTime(day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Calendar'),
        actions: [
          PopupMenuButton<CalendarFormat>(
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
            ],
          ),
        ],
      ),
      body: schedules.when(
        data: (scheduleList) => Column(
          children: [
            TableCalendar<MedicationSchedule>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => _getSchedulesForDay(day, scheduleList),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: _ScheduleList(
                schedules: _getSchedulesForDay(
                  _selectedDay,
                  scheduleList,
                ),
                date: _selectedDay,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<MedicationSchedule> schedules;
  final DateTime date;

  const _ScheduleList({
    required this.schedules,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No medications scheduled for ${_formatDate(date)}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                schedule.medicationName[0].toUpperCase(),
              ),
            ),
            title: Text(schedule.medicationName),
            subtitle: Text(
              '${schedule.dosageAmount} ${schedule.dosageUnit}\n'
              'Times: ${_formatTimes(schedule.scheduledTimes)}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimes(List<DateTime> times) {
    return times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .join(', ');
  }
}
