class User {
  final int? id;
  final String name;
  final String email;
  final String currency;
  final String? createdAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.currency = 'DOP',
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    currency: map['currency'] ?? 'DOP',
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'currency': currency,
  };

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? currency,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        currency: currency ?? this.currency,
        createdAt: createdAt,
      );

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}