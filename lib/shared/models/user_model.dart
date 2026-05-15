class UserModel {
  final String id;
  final String name;
  final String email;
  final String level;
  final String filiere;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.filiere,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      level: map['level'] ?? '',
      filiere: map['filiere'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'level': level,
      'filiere': filiere,
    };
  }
}