class User {
  final String id;
  final String email;
  final String name;
  final UserType type;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': type.toString().split('.').last,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      type: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
      ),
    );
  }
}

enum UserType {
  student,
  teacher,
  admin,
}