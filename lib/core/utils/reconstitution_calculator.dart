import 'package:logger/logger.dart';

class ReconstitutionCalculator {
  static final Logger _logger = Logger();

  /// Calculate the concentration after reconstitution
  /// Formula: concentration = powder_amount / solvent_volume
  static double calculateConcentration({
    required double powderAmount,
    required double solventVolume,
  }) {
    try {
      if (solventVolume <= 0) {
        throw ArgumentError('Solvent volume must be greater than 0');
      }
      
      final concentration = powderAmount / solventVolume;
      _logger.d('Calculated concentration: $concentration from powder: $powderAmount, solvent: $solventVolume');
      return concentration;
    } catch (e) {
      _logger.e('Error calculating concentration: $e');
      rethrow;
    }
  }

  /// Calculate the volume needed for a specific dose
  /// Formula: volume = desired_dose / concentration
  static double calculateVolumePerDose({
    required double desiredDose,
    required double concentration,
  }) {
    try {
      if (concentration <= 0) {
        throw ArgumentError('Concentration must be greater than 0');
      }
      
      final volume = desiredDose / concentration;
      _logger.d('Calculated volume per dose: $volume from dose: $desiredDose, concentration: $concentration');
      return volume;
    } catch (e) {
      _logger.e('Error calculating volume per dose: $e');
      rethrow;
    }
  }

  /// Calculate total solution volume after mixing
  /// This assumes the powder displaces some volume when dissolved
  static double calculateTotalSolutionVolume({
    required double powderAmount,
    required double solventVolume,
    double powderDisplacementFactor = 0.1, // Default 10% displacement
  }) {
    try {
      final displacement = powderAmount * powderDisplacementFactor;
      final totalVolume = solventVolume + displacement;
      _logger.d('Calculated total solution volume: $totalVolume (displacement: $displacement)');
      return totalVolume;
    } catch (e) {
      _logger.e('Error calculating total solution volume: $e');
      rethrow;
    }
  }

  /// Calculate how many doses can be made from the reconstituted solution
  static int calculateNumberOfDoses({
    required double totalSolutionVolume,
    required double volumePerDose,
  }) {
    try {
      if (volumePerDose <= 0) {
        throw ArgumentError('Volume per dose must be greater than 0');
      }
      
      final doses = (totalSolutionVolume / volumePerDose).floor();
      _logger.d('Calculated number of doses: $doses from total volume: $totalSolutionVolume, per dose: $volumePerDose');
      return doses;
    } catch (e) {
      _logger.e('Error calculating number of doses: $e');
      rethrow;
    }
  }

  /// Calculate the actual concentration based on total solution volume
  /// This is more accurate when considering powder displacement
  static double calculateActualConcentration({
    required double powderAmount,
    required double totalSolutionVolume,
  }) {
    try {
      if (totalSolutionVolume <= 0) {
        throw ArgumentError('Total solution volume must be greater than 0');
      }
      
      final concentration = powderAmount / totalSolutionVolume;
      _logger.d('Calculated actual concentration: $concentration from powder: $powderAmount, total volume: $totalSolutionVolume');
      return concentration;
    } catch (e) {
      _logger.e('Error calculating actual concentration: $e');
      rethrow;
    }
  }

  /// Validate reconstitution parameters
  static bool validateReconstitutionParams({
    required double powderAmount,
    required double solventVolume,
    required double desiredDose,
  }) {
    try {
      if (powderAmount <= 0) {
        _logger.w('Invalid powder amount: $powderAmount');
        return false;
      }
      
      if (solventVolume <= 0) {
        _logger.w('Invalid solvent volume: $solventVolume');
        return false;
      }
      
      if (desiredDose <= 0) {
        _logger.w('Invalid desired dose: $desiredDose');
        return false;
      }
      
      if (desiredDose > powderAmount) {
        _logger.w('Desired dose ($desiredDose) exceeds powder amount ($powderAmount)');
        return false;
      }
      
      return true;
    } catch (e) {
      _logger.e('Error validating reconstitution parameters: $e');
      return false;
    }
  }

  /// Complete reconstitution calculation with all parameters
  static Map<String, double> calculateComplete({
    required double powderAmount,
    required double solventVolume,
    required double desiredDose,
    double powderDisplacementFactor = 0.1,
  }) {
    try {
      if (!validateReconstitutionParams(
        powderAmount: powderAmount,
        solventVolume: solventVolume,
        desiredDose: desiredDose,
      )) {
        throw ArgumentError('Invalid reconstitution parameters');
      }

      final totalSolutionVolume = calculateTotalSolutionVolume(
        powderAmount: powderAmount,
        solventVolume: solventVolume,
        powderDisplacementFactor: powderDisplacementFactor,
      );

      final actualConcentration = calculateActualConcentration(
        powderAmount: powderAmount,
        totalSolutionVolume: totalSolutionVolume,
      );

      final volumePerDose = calculateVolumePerDose(
        desiredDose: desiredDose,
        concentration: actualConcentration,
      );

      final numberOfDoses = calculateNumberOfDoses(
        totalSolutionVolume: totalSolutionVolume,
        volumePerDose: volumePerDose,
      );

      return {
        'totalSolutionVolume': totalSolutionVolume,
        'actualConcentration': actualConcentration,
        'volumePerDose': volumePerDose,
        'numberOfDoses': numberOfDoses.toDouble(),
      };
    } catch (e) {
      _logger.e('Error in complete reconstitution calculation: $e');
      rethrow;
    }
  }
}
