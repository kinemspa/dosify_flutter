import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Medication extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final MedicationCategory category;

  @HiveField(3)
  final MedicationForm form;

  @HiveField(4)
  final double strength;

  @HiveField(5)
  final StrengthUnit strengthUnit;

  @HiveField(6)
  final double stock;

  @HiveField(20)
  final MedicationType type;

  @HiveField(21)
  final String unit;

  @HiveField(22)
  final bool? reconstitution;

  @HiveField(23)
  final List<String>? components;

  @HiveField(7)
  final StockUnit stockUnit;

  @HiveField(8)
  final double lowStockThreshold;

  @HiveField(9)
  final DateTime? expirationDate;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  // Injection-specific properties
  @HiveField(12)
  final double? concentration; // mg/ml for pre-filled syringes

  @HiveField(13)
  final double? volumePerContainer; // ml per vial/syringe

  @HiveField(14)
  final VialType? vialType;

  @HiveField(15)
  final String? brand;

  @HiveField(16)
  final String? batchNumber;

  @HiveField(17)
  final StorageConditions? storageConditions;

  @HiveField(18)
  final String? notes;

  @HiveField(19)
  final double? totalMedicineInStock; // Total mg/IU available across all containers

  Medication({
    required this.type,
    required this.unit,
    this.reconstitution,
    this.components,
    required this.id,
    required this.name,
    required this.category,
    required this.form,
    required this.strength,
    required this.strengthUnit,
    required this.stock,
    required this.stockUnit,
    required this.lowStockThreshold,
    this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
    this.concentration,
    this.volumePerContainer,
    this.vialType,
    this.brand,
    this.batchNumber,
    this.storageConditions,
    this.notes,
    this.totalMedicineInStock,
  });

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationToJson(this);

  // Calculate total medicine available
  double get totalMedicineAvailable {
    if (totalMedicineInStock != null) return totalMedicineInStock!;
    
    switch (form) {
      case MedicationForm.tablet:
      case MedicationForm.capsule:
        return stock * strength; // tablets * mg per tablet
      case MedicationForm.preFilledSyringe:
        return stock * (concentration ?? strength); // syringes * mg per syringe
      case MedicationForm.lyophilizedVial:
        return stock * strength; // vials * mg per vial
      case MedicationForm.liquidVial:
        return stock * (volumePerContainer ?? 1) * (concentration ?? strength);
      default:
        return stock * strength;
    }
  }

  // Check if this medication requires reconstitution
  bool get requiresReconstitution {
    return form == MedicationForm.lyophilizedVial;
  }

  // Get appropriate dose units for this medication
  List<DoseUnit> get availableDoseUnits {
    switch (category) {
      case MedicationCategory.oralMedication:
        return [DoseUnit.tablets, DoseUnit.mg];
      case MedicationCategory.injection:
        return [DoseUnit.mg, DoseUnit.ml, DoseUnit.iu];
      case MedicationCategory.peptide:
        return [DoseUnit.mg, DoseUnit.mcg, DoseUnit.iu];
      case MedicationCategory.topical:
        return [DoseUnit.mg, DoseUnit.grams];
      default:
        return [DoseUnit.mg];
    }
  }

  Medication copyWith({
    String? id,
    String? name,
    MedicationType? type,
    String? unit,
    bool? reconstitution,
    List<String>? components,
    MedicationCategory? category,
    MedicationForm? form,
    double? strength,
    StrengthUnit? strengthUnit,
    double? stock,
    StockUnit? stockUnit,
    double? lowStockThreshold,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? concentration,
    double? volumePerContainer,
    VialType? vialType,
    String? brand,
    String? batchNumber,
    StorageConditions? storageConditions,
    String? notes,
    double? totalMedicineInStock,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      reconstitution: reconstitution ?? this.reconstitution,
      components: components ?? this.components,
      category: category ?? this.category,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      stock: stock ?? this.stock,
      stockUnit: stockUnit ?? this.stockUnit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      concentration: concentration ?? this.concentration,
      volumePerContainer: volumePerContainer ?? this.volumePerContainer,
      vialType: vialType ?? this.vialType,
      brand: brand ?? this.brand,
      batchNumber: batchNumber ?? this.batchNumber,
      storageConditions: storageConditions ?? this.storageConditions,
      notes: notes ?? this.notes,
      totalMedicineInStock: totalMedicineInStock ?? this.totalMedicineInStock,
    );
  }
}

// Medication Types
@HiveType(typeId: 9)
enum MedicationType {
  @HiveField(0)
  tablet,
  @HiveField(1)
  capsule,
  @HiveField(2)
  liquid,
  @HiveField(3)
  injection,
  @HiveField(4)
  topical,
  @HiveField(5)
  inhalation,
}

// Medication Categories
@HiveType(typeId: 1)
enum MedicationCategory {
  @HiveField(0)
  oralMedication,
  @HiveField(1)
  injection,
  @HiveField(2)
  peptide,
  @HiveField(3)
  topical,
  @HiveField(4)
  nasal,
  @HiveField(5)
  ophthalmic,
  @HiveField(6)
  otic,
  @HiveField(7)
  inhalation,
}

// Medication Forms
@HiveType(typeId: 2)
enum MedicationForm {
  @HiveField(0)
  tablet,
  @HiveField(1)
  capsule,
  @HiveField(2)
  preFilledSyringe, // Pre-filled with known concentration
  @HiveField(3)
  lyophilizedVial, // Freeze-dried powder requiring reconstitution
  @HiveField(4)
  liquidVial, // Ready-to-use liquid
  @HiveField(5)
  cream,
  @HiveField(6)
  gel,
  @HiveField(7)
  patch,
  @HiveField(8)
  spray,
  @HiveField(9)
  drops,
  @HiveField(10)
  inhaler,
}

// Strength Units
@HiveType(typeId: 3)
enum StrengthUnit {
  @HiveField(0)
  mg,
  @HiveField(1)
  mcg,
  @HiveField(2)
  g,
  @HiveField(3)
  iu, // International Units
  @HiveField(4)
  units,
  @HiveField(5)
  percent,
  @HiveField(6)
  mgPerMl,
  @HiveField(7)
  mcgPerMl,
}

// Stock Units
@HiveType(typeId: 4)
enum StockUnit {
  @HiveField(0)
  tablets,
  @HiveField(1)
  capsules,
  @HiveField(2)
  syringes,
  @HiveField(3)
  vials,
  @HiveField(4)
  bottles,
  @HiveField(5)
  tubes,
  @HiveField(6)
  patches,
  @HiveField(7)
  ml,
  @HiveField(8)
  grams,
}

// Dose Units
@HiveType(typeId: 5)
enum DoseUnit {
  @HiveField(0)
  mg,
  @HiveField(1)
  mcg,
  @HiveField(2)
  g,
  @HiveField(3)
  iu,
  @HiveField(4)
  units,
  @HiveField(5)
  ml,
  @HiveField(6)
  tablets,
  @HiveField(7)
  capsules,
  @HiveField(8)
  drops,
  @HiveField(9)
  grams,
}

// Vial Types for injections
@HiveType(typeId: 6)
enum VialType {
  @HiveField(0)
  singleDose,
  @HiveField(1)
  multiDose,
  @HiveField(2)
  bacteriostatic,
}

// Storage Conditions
@HiveType(typeId: 11)
enum StorageConditions {
  @HiveField(0)
  roomTemperature, // 15-25°C
  @HiveField(1)
  refrigerated, // 2-8°C
  @HiveField(2)
  frozen, // -20°C
  @HiveField(3)
  controlledRoomTemperature, // 20-25°C
}

// Helper class for medication form validation
class MedicationFormHelper {
  static bool requiresConcentration(MedicationForm form) {
    return form == MedicationForm.preFilledSyringe || 
           form == MedicationForm.liquidVial;
  }

  static bool requiresVolume(MedicationForm form) {
    return form == MedicationForm.preFilledSyringe || 
           form == MedicationForm.liquidVial ||
           form == MedicationForm.lyophilizedVial;
  }

  static bool requiresReconstitution(MedicationForm form) {
    return form == MedicationForm.lyophilizedVial;
  }

  static List<StrengthUnit> getValidStrengthUnits(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.oralMedication:
        return [StrengthUnit.mg, StrengthUnit.mcg, StrengthUnit.g];
      case MedicationCategory.injection:
        return [StrengthUnit.mg, StrengthUnit.mcg, StrengthUnit.iu, StrengthUnit.units, StrengthUnit.mgPerMl];
      case MedicationCategory.peptide:
        return [StrengthUnit.mg, StrengthUnit.mcg, StrengthUnit.iu];
      case MedicationCategory.topical:
        return [StrengthUnit.mg, StrengthUnit.g, StrengthUnit.percent];
      default:
        return StrengthUnit.values;
    }
  }

  static List<StockUnit> getValidStockUnits(MedicationForm form) {
    switch (form) {
      case MedicationForm.tablet:
        return [StockUnit.tablets];
      case MedicationForm.capsule:
        return [StockUnit.capsules];
      case MedicationForm.preFilledSyringe:
        return [StockUnit.syringes];
      case MedicationForm.lyophilizedVial:
      case MedicationForm.liquidVial:
        return [StockUnit.vials];
      case MedicationForm.cream:
      case MedicationForm.gel:
        return [StockUnit.tubes, StockUnit.grams];
      case MedicationForm.patch:
        return [StockUnit.patches];
      case MedicationForm.spray:
      case MedicationForm.drops:
        return [StockUnit.bottles, StockUnit.ml];
      default:
        return StockUnit.values;
    }
  }
}
