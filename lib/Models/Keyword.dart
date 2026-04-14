class Keyword {
  final int? id;
  final String keyword;
  final int categoryId;

  const Keyword({
    this.id,
    required this.keyword,
    required this.categoryId,
  });

  factory Keyword.fromMap(Map<String, dynamic> map) => Keyword(
    id: map['id'],
    keyword: map['keyword'],
    categoryId: map['category_id'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'keyword': keyword,
    'category_id': categoryId,
  };

  Keyword copyWith({
    int? id,
    String? keyword,
    int? categoryId,
  }) =>
      Keyword(
        id: id ?? this.id,
        keyword: keyword ?? this.keyword,
        categoryId: categoryId ?? this.categoryId,
      );

  @override
  String toString() => 'Keyword(id: $id, keyword: $keyword, categoryId: $categoryId)';
}