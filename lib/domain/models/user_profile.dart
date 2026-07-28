class UserProfile {
  UserProfile({
    required this.id,
    required this.username,
    this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  String id;
  String username;
  String? email;
  String passwordHash;
  DateTime createdAt;

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
