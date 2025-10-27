import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// User profile provider
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final authService = ref.watch(authServiceProvider);
  // This would typically fetch from Firestore
  return {
    'uid': user.uid,
    'email': user.email,
    'displayName': user.displayName,
    'photoURL': user.photoURL,
  };
});

// Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await _authService.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }
}


