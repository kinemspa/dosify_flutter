import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/auth_service.dart';
import '../data/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<fb_auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (fbUser) => fbUser == null
        ? null
        : User(
            id: fbUser.uid,
            email: fbUser.email!,
            name: fbUser.displayName ?? fbUser.email!.split('@')[0],
            photoUrl: fbUser.photoURL,
          ),
    loading: () => null,
    error: (_, __) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
