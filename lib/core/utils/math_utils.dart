import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MathUtils {
  static final Logger _logger = Logger();

  /// Calculate time left until next dose
  /// [nextDoseTime] should be formatted as 'HH:mm'
  static Duration timeLeftUntilNextDose(String nextDoseTime) {
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final nextDoseDateTime = DateTime.parse('$today $nextDoseTime:00');

      if (now.isAfter(nextDoseDateTime)) {
        _logger.i('Next dose time has already passed for today.');
        return Duration.zero;
      }

      final duration = nextDoseDateTime.difference(now);
      _logger.d('Time left until next dose: $duration');
      return duration;
    } catch (e) {
      _logger.e('Error calculating time left until next dose: $e');
      return Duration.zero;
    }
  }

  /// Calculate expiration days left
  /// [expirationDate] should be in the format 'yyyy-MM-dd'
  static int expirationDaysLeft(String expirationDate) {
    try {
      final expiration = DateTime.parse('$expirationDate 00:00:00');
      final now = DateTime.now();

      if (now.isAfter(expiration)) {
        _logger.i('Medication has already expired.');
        return 0;
      }

      final daysLeft = expiration.difference(now).inDays;
      _logger.d('Days left until expiration: $daysLeft');
      return daysLeft;
    } catch (e) {
      _logger.e('Error calculating expiration days left: $e');
      return 0;
    }
  }

  /// Calculate number of doses that can be taken before refilling is needed
  /// [currentStock] in the same unit as [doseAmount]
  static int dosesBeforeRefill(double currentStock, double doseAmount) {
    try {
      if (doseAmount <= 0) {
        _logger.w('Invalid dose amount: $doseAmount');
        return 0;
      }

      final doses = (currentStock / doseAmount).floor();
      _logger.d('Number of doses before refill is needed: $doses');
      return doses;
    } catch (e) {
      _logger.e('Error calculating doses before refill: $e');
      return 0;
    }
  }

  /// Cycle forecast calculation
  /// This assumes daily dosing within cycle period
  static int cycleForecast(double totalDoses, int daysInCycle) {
    try {
      if (daysInCycle <= 0) {
        _logger.w('Invalid cycle days: $daysInCycle');
        return 0;
      }

      final cycles = (totalDoses / daysInCycle).floor();
      _logger.d('Total cycles possible: $cycles');
      return cycles;
    } catch (e) {
      _logger.e('Error calculating cycle forecast: $e');
      return 0;
    }
  }

  /// Calculate dosage adjustment steps
  /// [titrationSteps] list of step increases
  static List<double> calculateTitrationSteps(List<double> titrationSteps, double startingDose) {
    try {
      List<double> steps = [startingDose];

      for (final step in titrationSteps) {
        final newDose = steps.last + step;
        steps.add(newDose);
      }

      _logger.d('Calculated titration steps: $steps');
      return steps;
    } catch (e) {
      _logger.e('Error calculating titration steps: $e');
      return [];
    }
  }
}

