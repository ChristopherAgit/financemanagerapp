/// Periodos válidos para un presupuesto
enum BudgetPeriod { weekly, monthly }

extension BudgetPeriodExtension on BudgetPeriod {
  String get value => name; // 'weekly' | 'monthly'

  static BudgetPeriod fromString(String value) =>
      BudgetPeriod.values.firstWhere(
            (e) => e.value == value,
        orElse: () => BudgetPeriod.monthly,
      );
}

class Budget {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final BudgetPeriod period;
  final String? createdAt;

  const Budget({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    this.period = BudgetPeriod.monthly,
    this.createdAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    id: map['id'],
    userId: map['user_id'],
    categoryId: map['category_id'],
    amount: (map['amount'] as num).toDouble(),
    period: BudgetPeriodExtension.fromString(map['period'] ?? 'monthly'),
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'category_id': categoryId,
    'amount': amount,
    'period': period.value,
  };

  Budget copyWith({
    int? id,
    int? userId,
    int? categoryId,
    double? amount,
    BudgetPeriod? period,
  }) =>
      Budget(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'Budget(id: $id, categoryId: $categoryId, amount: $amount, period: ${period.value})';
}