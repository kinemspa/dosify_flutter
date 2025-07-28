import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/report_providers.dart';

class ReportExportScreen extends ConsumerStatefulWidget {
  const ReportExportScreen({super.key});

  @override
  ConsumerState<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends ConsumerState<ReportExportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: _endDate,
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _exportAndShare() async {
    setState(() => _isExporting = true);

    try {
      final csvData = await ref.read(
        reportExportProvider({'startDate': _startDate, 'endDate': _endDate}).future,
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'dosify_report_${_formatDate(_startDate)}_${_formatDate(_endDate)}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Dosify Report: ${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('End Date'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDate,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Report Contents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Medication inventory movements'),
                    Text('• Stock levels and adjustments'),
                    Text('• Consumption records'),
                    Text('• Purchase and disposal records'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _exportAndShare,
                child: _isExporting
                    ? const CircularProgressIndicator()
                    : const Text('Export and Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
