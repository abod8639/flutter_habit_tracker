import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  factory AuthModel.fromFirebaseUser(User user) {
    return AuthModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
