import '../../Models/ExchangeRate.dart';
import '../Database/DatabaseHelper.dart';

class ExchangeRateRepository {
  final DatabaseHelper _db;

  ExchangeRateRepository(this._db);

  Future<int> insert(ExchangeRate rate) async {
    final db = await _db.database;
    return await db.insert('exchange_rates', rate.toMap());
  }

  Future<ExchangeRate?> findLatest(String fromCurrency, String toCurrency) async
  {
    final db = await _db.database;
    final result = await db.query(
      'exchange_rates',
      where: 'from_currency = ? AND to_currency = ?',
      whereArgs: [fromCurrency, toCurrency],
      orderBy: 'fetched_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ExchangeRate.fromMap(result.first);
  }

  Future<List<ExchangeRate>> findAll() async {
    final db = await _db.database;
    final result =
    await db.query('exchange_rates', orderBy: 'fetched_at DESC');
    return result.map(ExchangeRate.fromMap).toList();
  }

  Future<void> pruneOldRates() async {
    final db = await _db.database;
    await db.rawDelete('''
      DELETE FROM exchange_rates
      WHERE id NOT IN (
        SELECT MAX(id) FROM exchange_rates
        GROUP BY from_currency, to_currency
      )
    ''');
  }
}