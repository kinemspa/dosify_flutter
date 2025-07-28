import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_schedule.dart';
import '../providers/schedule_provider.dart';
import 'schedule_form_screen.dart';

class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Navigate to calendar view
            },
          ),
        ],
      ),
      body: schedules.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No medication schedules yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to create a new schedule',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return _ScheduleListItem(schedule: schedule);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show medication picker dialog before navigating to form
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => ScheduleFormScreen(
          //     medicationId: selectedMedication.id,
          //     medicationName: selectedMedication.name,
          //   ),
          // ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ScheduleListItem extends ConsumerWidget {
  final MedicationSchedule schedule;

  const _ScheduleListItem({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(schedule.medicationName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${schedule.dosageAmount} ${schedule.dosageUnit} - '
              '${_formatFrequency(schedule)}',
            ),
            Text(
              _formatTimes(schedule.scheduledTimes),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.isActive,
              onChanged: (value) {
                ref.read(scheduleRepositoryProvider).updateSchedule(
                      schedule.copyWith(isActive: value),
                    );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _ScheduleOptionsSheet(schedule: schedule),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScheduleFormScreen(
              medicationId: schedule.medicationId,
              medicationName: schedule.medicationName,
              existingSchedule: schedule,
            ),
          ));
        },
      ),
    );
  }

  String _formatFrequency(MedicationSchedule schedule) {
    switch (schedule.frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        final days = schedule.weekdays
            .map((day) => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day])
            .join(', ');
        return 'Weekly on $days';
      case 'monthly':
        return 'Monthly on day ${schedule.startDate.day}';
      case 'custom':
        return 'Every ${schedule.intervalDays} days';
      default:
        return schedule.frequency;
    }
  }

  String _formatTimes(List<DateTime> times) {
    return times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .join(', ');
  }
}

class _ScheduleOptionsSheet extends ConsumerWidget {
  final MedicationSchedule schedule;

  const _ScheduleOptionsSheet({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Schedule'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ScheduleFormScreen(
                  medicationId: schedule.medicationId,
                  medicationName: schedule.medicationName,
                  existingSchedule: schedule,
                ),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete Schedule'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Schedule'),
                  content: const Text(
                    'Are you sure you want to delete this schedule? '
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                Navigator.of(context).pop();
                await ref
                    .read(scheduleRepositoryProvider)
                    .deleteSchedule(schedule.id);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
