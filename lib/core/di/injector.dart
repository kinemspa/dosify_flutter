import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../data/hive/hive_service.dart';
import '../data/repositories/medication_repository.dart';
import '../data/repositories/hive_medication_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  final logger = Logger();
  
  try {
    // Register Logger
    getIt.registerLazySingleton<Logger>(() => Logger());
    
    // Open Hive boxes
    await HiveService.openBoxes();
    
    // Register repositories
    getIt.registerLazySingleton<MedicationRepository>(
      () => HiveMedicationRepository(),
    );
    
    logger.i('Dependency injection setup completed');
  } catch (e, stackTrace) {
    logger.e('Failed to setup dependency injection', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
