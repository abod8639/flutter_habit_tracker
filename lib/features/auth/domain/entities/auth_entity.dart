class AuthEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
