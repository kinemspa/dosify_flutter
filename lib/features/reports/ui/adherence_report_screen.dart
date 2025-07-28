import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_providers.dart';

class AdherenceReportScreen extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String? medicationId;

  const AdherenceReportScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
    this.medicationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherenceReport = ref.watch(adherenceReportProvider({
      'startDate': startDate,
      'endDate': endDate,
      'medicationId': medicationId,
    }));

    return Scaffold(
      appBar: AppBar(title: const Text('Adherence Report')),
      body: adherenceReport.when(
        data: (report) => _buildReportView(context, report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildReportView(BuildContext context, AdherenceReport report) {
    final adherenceRates = report.adherenceRates;
    final overallRate = report.overallAdherenceRate;
    final missedSchedules = report.missedDoseSchedules;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOverallAdherenceCard(overallRate),
        const SizedBox(height: 24),
        _buildSectionTitle('Adherence by Medication'),
        ...adherenceRates.entries.map(
          (entry) => _buildAdherenceRateCard(entry.key, entry.value),
        ),
        if (missedSchedules.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Missed Dose Schedules'),
          ...missedSchedules.map((schedule) => _buildScheduleCard(schedule)),
        ],
      ],
    );
  }

  Widget _buildOverallAdherenceCard(double rate) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Overall Adherence Rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              value: rate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAdherenceColor(rate),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${(rate * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getAdherenceColor(rate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceRateCard(String medicationId, double rate) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(medicationId),
        subtitle: LinearProgressIndicator(
          value: rate,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getAdherenceColor(rate)),
        ),
        trailing: Text(
          '${(rate * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getAdherenceColor(rate),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(MedicationSchedule schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.orange),
        title: Text(schedule.medicationName),
        subtitle: Text(
          'Frequency: ${schedule.frequency}\n'
          'Dose: ${schedule.dosageAmount} ${schedule.dosageUnit}',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 0.9) {
      return Colors.green;
    } else if (rate >= 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
