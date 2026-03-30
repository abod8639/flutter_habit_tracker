import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/models/user_model.dart';
// import 'package:habit_tracker/view/homepage/HomeScreen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Convert Firebase User to UserModel
  UserModel? _userFromFirebase(User? user) {
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _userFromFirebase(result.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
        await result.user?.reload();
      }

      return _userFromFirebase(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // if (googleUser == null) {
      //   // User cancelled the sign-in
      //   return null;
      // }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;


      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        // accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result =
          await _auth.signInWithCredential(credential);

          // go to home screen
          // if (result.user != null) {
          //   Get.to(const HomeScreen());
          // }

      return _userFromFirebase(result.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw '${S.current.authErrorGoogle}: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw '${S.current.authErrorSignOut}: $e';
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return S.current.authErrorUserNotFound;
      case 'wrong-password':
        return S.current.authErrorWrongPassword;
      case 'email-already-in-use':
        return S.current.authErrorEmailInUse;
      case 'invalid-email':
        return S.current.authErrorInvalidEmail;
      case 'weak-password':
        return S.current.authErrorWeakPassword;
      case 'operation-not-allowed':
        return S.current.authErrorDefault;
      case 'user-disabled':
        return S.current.authErrorDefault;
      case 'too-many-requests':
        return S.current.authErrorTooManyRequests;
      case 'network-request-failed':
        return S.current.authErrorNetworkFailed;
      default:
        return '${S.current.authErrorDefault}: ${e.message ?? e.code}';
    }
  }
}
