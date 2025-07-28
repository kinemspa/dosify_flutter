import 'package:hive/hive.dart';
import '../../../core/data/models/dose_log.dart';
import '../../../core/domain/repositories/dose_log_repository.dart';

class DoseLogRepositoryImpl implements DoseLogRepository {
  final Box<DoseLog> _logBox;

  DoseLogRepositoryImpl(this._logBox);

  @override
  Future<List<DoseLog>> getAllLogs() async {
    return _logBox.values.toList();
  }

  @override
  Future<DoseLog?> getLogById(String id) async {
    return _logBox.get(id);
  }

  @override
  Future<void> addLog(DoseLog log) async {
    await _logBox.put(log.id, log);
  }

  @override
  Future<void> updateLog(DoseLog log) async {
    await _logBox.put(log.id, log);
  }

  @override
  Future<void> deleteLog(String id) async {
    await _logBox.delete(id);
  }

  @override
  Future<List<DoseLog>> getLogsForSchedule(String scheduleId) async {
    return _logBox.values
        .where((log) => log.scheduleId == scheduleId)
        .toList();
  }

  @override
  Future<List<DoseLog>> getLogsForDateRange(DateTime start, DateTime end) async {
    return _logBox.values
        .where((log) =>
            log.takenTime.isAfter(start) && log.takenTime.isBefore(end))
        .toList();
  }

  @override
  Future<List<DoseLog>> getRecentLogs(int limit) async {
    final logs = _logBox.values.toList();
    logs.sort((a, b) => b.takenTime.compareTo(a.takenTime));
    return logs.take(limit).toList();
  }

  @override
  Stream<List<DoseLog>> watchAllLogs() {
    return _logBox.watch().map((_) => _logBox.values.toList());
  }
}
