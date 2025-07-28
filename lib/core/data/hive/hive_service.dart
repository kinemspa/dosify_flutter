import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../models/medication.dart';
import '../models/dose.dart';
import '../models/schedule.dart';

class HiveService {
  static final Logger _logger = Logger();
  
  static const String medicationBoxName = 'medications';
  static const String scheduleBoxName = 'schedules';
  static const String doseBoxName = 'doses';

  static Future<void> openBoxes() async {
    try {
      // Try to open boxes, delete and recreate if there are adapter conflicts
      await _openBoxSafely<Medication>(medicationBoxName);
      await _openBoxSafely<Schedule>(scheduleBoxName);
      await _openBoxSafely<Dose>(doseBoxName);
      _logger.i('All Hive boxes opened successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to open Hive boxes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  static Future<void> _openBoxSafely<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (e) {
      _logger.w('Failed to open box $boxName, attempting to delete and recreate: $e');
      try {
        await Hive.deleteBoxFromDisk(boxName);
        await Hive.openBox<T>(boxName);
        _logger.i('Successfully recreated box $boxName');
      } catch (e2) {
        _logger.e('Failed to recreate box $boxName: $e2');
        rethrow;
      }
    }
  }

  static Box<Medication> get medicationBox => Hive.box<Medication>(medicationBoxName);
  static Box<Schedule> get scheduleBox => Hive.box<Schedule>(scheduleBoxName);
  static Box<Dose> get doseBox => Hive.box<Dose>(doseBoxName);

  static Future<void> closeBoxes() async {
    try {
      await Future.wait([
        medicationBox.close(),
        scheduleBox.close(),
        doseBox.close(),
      ]);
      _logger.i('All Hive boxes closed successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to close Hive boxes', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> clearAllData() async {
    try {
      await Future.wait([
        medicationBox.clear(),
        scheduleBox.clear(),
        doseBox.clear(),
      ]);
      _logger.i('All Hive data cleared successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear Hive data', error: e, stackTrace: stackTrace);
    }
  }
}
