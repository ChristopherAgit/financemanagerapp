import '../../Models/Expense.dart';
import '../Database/DatabaseHelper.dart';

class ExpenseRepository {
  final DatabaseHelper _db;

  ExpenseRepository(this._db);

  Future<int> insert(Expense expense) async {
    final db = await _db.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<Expense?> findById(int id) async {
    final db = await _db.database;
    final result =
    await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Expense.fromMap(result.first);
  }

  Future<List<Expense>> findByUser(int userId) async {
    final db = await _db.database;
    final result = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> findByUserAndCategory(int userId, int categoryId) async
  {
    final db = await _db.database;
    final result = await db.query(
      'expenses',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
      orderBy: 'date DESC',
    );
    return result.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> findByDateRange(int userId, String from, String to) async
  {
    final db = await _db.database;
    final result = await db.query(
      'expenses',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, from, to],
      orderBy: 'date DESC',
    );
    return result.map(Expense.fromMap).toList();
  }

  Future<double> sumByUser(int userId, {String? from, String? to}) async
  {
    final db = await _db.database;
    String where = 'user_id = ?';
    List<dynamic> args = [userId];

    if (from != null && to != null) {
      where += ' AND date BETWEEN ? AND ?';
      args.addAll([from, to]);
    }

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE $where',
      args,
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> sumGroupedByCategory(int userId, {String? from, String? to}) async
  {
    final db = await _db.database;
    String where = 'e.user_id = ?';
    List<dynamic> args = [userId];

    if (from != null && to != null) {
      where += ' AND e.date BETWEEN ? AND ?';
      args.addAll([from, to]);
    }

    return await db.rawQuery('''
      SELECT c.id, c.name, c.color, c.icon,
             COALESCE(SUM(e.amount), 0) as total
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE $where
      GROUP BY c.id
      ORDER BY total DESC
    ''', args);
  }

  Future<int> update(Expense expense) async {
    final db = await _db.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}