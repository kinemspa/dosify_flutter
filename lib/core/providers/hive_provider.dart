import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/hive_service.dart';

part 'hive_provider.g.dart';

@riverpod
HiveService hiveService(HiveServiceRef ref) {
  return HiveService();
}
