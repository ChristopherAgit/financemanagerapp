class Expense {
  final int? id;
  final int userId;
  final String description;
  final double amount;
  final String currency;
  final double? amountConverted;
  final String date;
  final int categoryId;
  final int? suggestedCategoryId;
  final bool wasCorrected;
  final String? notes;
  final String? createdAt;

  const Expense({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.currency,
    this.amountConverted,
    required this.date,
    required this.categoryId,
    this.suggestedCategoryId,
    this.wasCorrected = false,
    this.notes,
    this.createdAt,
  });

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    userId: map['user_id'],
    description: map['description'],
    amount: (map['amount'] as num).toDouble(),
    currency: map['currency'] ?? 'DOP',
    amountConverted: map['amount_converted'] != null
        ? (map['amount_converted'] as num).toDouble()
        : null,
    date: map['date'],
    categoryId: map['category_id'],
    suggestedCategoryId: map['suggested_category_id'],
    wasCorrected: map['was_corrected'] == 1,
    notes: map['notes'],
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'description': description,
    'amount': amount,
    'currency': currency,
    'amount_converted': amountConverted,
    'date': date,
    'category_id': categoryId,
    'suggested_category_id': suggestedCategoryId,
    'was_corrected': wasCorrected ? 1 : 0,
    'notes': notes,
  };

  Expense copyWith({
    int? id,
    int? userId,
    String? description,
    double? amount,
    String? currency,
    double? amountConverted,
    String? date,
    int? categoryId,
    int? suggestedCategoryId,
    bool? wasCorrected,
    String? notes,
  }) =>
      Expense(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        amountConverted: amountConverted ?? this.amountConverted,
        date: date ?? this.date,
        categoryId: categoryId ?? this.categoryId,
        suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
        wasCorrected: wasCorrected ?? this.wasCorrected,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'Expense(id: $id, description: $description, amount: $amount, categoryId: $categoryId)';
}