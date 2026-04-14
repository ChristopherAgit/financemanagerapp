class ExchangeRate {
  final int? id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final String? fetchedAt;

  const ExchangeRate({
    this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    this.fetchedAt,
  });

  factory ExchangeRate.fromMap(Map<String, dynamic> map) => ExchangeRate(
    id: map['id'],
    fromCurrency: map['from_currency'],
    toCurrency: map['to_currency'],
    rate: (map['rate'] as num).toDouble(),
    fetchedAt: map['fetched_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'from_currency': fromCurrency,
    'to_currency': toCurrency,
    'rate': rate,
  };

  /// Convierte un monto usando esta tasa
  double convert(double amount) => amount * rate;

  ExchangeRate copyWith({
    int? id,
    String? fromCurrency,
    String? toCurrency,
    double? rate,
  }) =>
      ExchangeRate(
        id: id ?? this.id,
        fromCurrency: fromCurrency ?? this.fromCurrency,
        toCurrency: toCurrency ?? this.toCurrency,
        rate: rate ?? this.rate,
        fetchedAt: fetchedAt,
      );

  @override
  String toString() =>
      'ExchangeRate($fromCurrency → $toCurrency: $rate)';
}