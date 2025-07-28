import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/medication_schedule.dart';
import '../../../core/providers/auth_provider.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final String medicationId;
  final String medicationName;
  final MedicationSchedule? existingSchedule;

  const ScheduleFormScreen({
    super.key,
    required this.medicationId,
    required this.medicationName,
    this.existingSchedule,
  });

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dosageAmountController;
  late TextEditingController _dosageUnitController;
  late TextEditingController _notesController;
  late DateTime _startDate;
  DateTime? _endDate;
  String _frequency = 'daily';
  List<TimeOfDay> _scheduledTimes = [];
  List<int> _selectedWeekdays = [];
  int _intervalDays = 1;
  bool _reminderEnabled = true;
  int _reminderMinutesBefore = 15;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final schedule = widget.existingSchedule;
    
    _dosageAmountController = TextEditingController(
      text: schedule?.dosageAmount.toString() ?? '',
    );
    _dosageUnitController = TextEditingController(
      text: schedule?.dosageUnit ?? '',
    );
    _notesController = TextEditingController(
      text: schedule?.notes ?? '',
    );
    
    _startDate = schedule?.startDate ?? DateTime.now();
    _endDate = schedule?.endDate;
    _frequency = schedule?.frequency ?? 'daily';
    _scheduledTimes = schedule?.scheduledTimes
            .map((dt) => TimeOfDay(hour: dt.hour, minute: dt.minute))
            .toList() ??
        [];
    _selectedWeekdays = schedule?.weekdays ?? [];
    _intervalDays = schedule?.intervalDays ?? 1;
    _reminderEnabled = schedule?.reminderEnabled ?? true;
    _reminderMinutesBefore = schedule?.reminderMinutesBefore ?? 15;
  }

  @override
  void dispose() {
    _dosageAmountController.dispose();
    _dosageUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && !_scheduledTimes.contains(time)) {
      setState(() {
        _scheduledTimes = [..._scheduledTimes, time]..sort((a, b) {
            return a.hour * 60 + a.minute - (b.hour * 60 + b.minute);
          });
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
      _selectedWeekdays.sort();
    });
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one time')),
      );
      return;
    }
    if (_frequency == 'weekly' && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one weekday')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final schedule = MedicationSchedule(
        id: widget.existingSchedule?.id ?? const Uuid().v4(),
        medicationId: widget.medicationId,
        medicationName: widget.medicationName,
        scheduledTimes: _scheduledTimes
            .map((t) => DateTime(
                  _startDate.year,
                  _startDate.month,
                  _startDate.day,
                  t.hour,
                  t.minute,
                ))
            .toList(),
        frequency: _frequency,
        dosageAmount: int.parse(_dosageAmountController.text),
        dosageUnit: _dosageUnitController.text,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text,
        weekdays: _selectedWeekdays,
        intervalDays: _intervalDays,
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
        createdAt: widget.existingSchedule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save schedule using schedule repository
      
      if (mounted) {
        Navigator.of(context).pop(schedule);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingSchedule == null
              ? 'Create Schedule'
              : 'Edit Schedule',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Medication: ${widget.medicationName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Dosage
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dosageAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dosage amount';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dosageUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Frequency
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Weekly selection
            if (_frequency == 'weekly') ...[
              const Text('Select Days:'),
              Wrap(
                spacing: 8.0,
                children: [
                  for (int i = 0; i < 7; i++)
                    FilterChip(
                      label: Text(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i]),
                      selected: _selectedWeekdays.contains(i),
                      onSelected: (_) => _toggleWeekday(i),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Custom interval
            if (_frequency == 'custom') ...[
              Row(
                children: [
                  const Text('Every '),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: _intervalDays.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _intervalDays = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                  const Text(' days'),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Times
            const Text('Times:'),
            Wrap(
              spacing: 8.0,
              children: [
                for (final time in _scheduledTimes)
                  Chip(
                    label: Text(time.format(context)),
                    onDeleted: () {
                      setState(() {
                        _scheduledTimes.remove(time);
                      });
                    },
                  ),
                ActionChip(
                  label: const Text('Add Time'),
                  onPressed: _selectTime,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date range
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate.toString().split(' ')[0]),
                    onTap: _selectStartDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date (Optional)'),
                    subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not set'),
                    onTap: _selectEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Reminders
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
            ),
            if (_reminderEnabled) ...[
              Row(
                children: [
                  const Text('Remind '),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: _reminderMinutesBefore.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _reminderMinutesBefore = int.tryParse(value) ?? 15;
                        });
                      },
                    ),
                  ),
                  const Text(' minutes before'),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
