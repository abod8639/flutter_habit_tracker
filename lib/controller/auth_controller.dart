import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/user_model.dart';
import 'package:habit_tracker/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable user
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _currentUser.value =
          user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint(e.toString());
      Get.snackbar(
        S.current.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint(e.toString());
      Get.snackbar(
        S.current.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.signInWithGoogle();

      isLoading.value = false;

      if (user == null) {
        // User cancelled
        return false;
      }

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint(e.toString());
      Get.snackbar(
        S.current.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      debugPrint(e.toString());
      Get.snackbar(
        S.current.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(email: email);

      isLoading.value = false;
      Get.snackbar(
        S.current.success,
        S.current.resetPasswordSuccess,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      debugPrint(e.toString());
      Get.snackbar(
        S.current.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser.value != null;
}
