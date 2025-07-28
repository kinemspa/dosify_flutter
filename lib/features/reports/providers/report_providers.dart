import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/providers/inventory_providers.dart';
import '../../medication/domain/providers/medication_providers.dart';
import '../../scheduling/providers/schedule_provider.dart';
import '../models/report_models.dart';
import '../services/report_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  final medications = ref.watch(medicationsProvider).value ?? [];
  final inventoryEntries = ref.watch(inventoryEntriesProvider).value ?? [];
  final transactions = ref.watch(inventoryTransactionsProvider).value ?? [];
  final schedules = ref.watch(scheduleListProvider).value ?? [];

  return ReportService(
    medications: medications,
    inventoryEntries: inventoryEntries,
    transactions: transactions,
    schedules: schedules,
  );
});

final medicationReportProvider = FutureProvider.family<MedicationReport, ({String medicationId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.generateMedicationReport(
    params.medicationId,
    params.startDate,
    params.endDate,
  );
});

final inventoryReportProvider = FutureProvider.family<InventoryReport, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.generateInventoryReport(
    params.startDate,
    params.endDate,
  );
});

final adherenceReportProvider = FutureProvider.family<AdherenceReport, ({DateTime startDate, DateTime endDate, String? medicationId})>((ref, params) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.generateAdherenceReport(
    params.startDate,
    params.endDate,
    medicationId: params.medicationId,
  );
});

final reportExportProvider = FutureProvider.family<String, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.exportToCSV(
    params.startDate,
    params.endDate,
  );
});
