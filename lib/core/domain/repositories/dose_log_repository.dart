import '../../../core/data/models/dose_log.dart';

abstract class DoseLogRepository {
  Future<List<DoseLog>> getAllLogs();
  Future<DoseLog?> getLogById(String id);
  Future<void> addLog(DoseLog log);
  Future<void> updateLog(DoseLog log);
  Future<void> deleteLog(String id);
  Future<List<DoseLog>> getLogsForSchedule(String scheduleId);
  Future<List<DoseLog>> getLogsForDateRange(DateTime start, DateTime end);
  Future<List<DoseLog>> getRecentLogs(int limit);
  Stream<List<DoseLog>> watchAllLogs();
}
