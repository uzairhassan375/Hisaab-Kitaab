class UserModel {
  final String userId;
  final String name;
  final String email;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}


