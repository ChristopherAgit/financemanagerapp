class Category {
  final int? id;
  final String name;
  final String? icon;
  final String? color;
  final bool isDefault;

  const Category({
    this.id,
    required this.name,
    this.icon,
    this.color,
    this.isDefault = false,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    icon: map['icon'],
    color: map['color'],
    isDefault: map['is_default'] == 1,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'is_default': isDefault ? 1 : 0,
  };

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    bool? isDefault,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        isDefault: isDefault ?? this.isDefault,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}