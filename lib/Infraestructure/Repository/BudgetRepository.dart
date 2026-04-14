import '../../Models/Budget.dart';
import '../Database/DatabaseHelper.dart';


class BudgetRepository {
  final DatabaseHelper _db;

  BudgetRepository(this._db);

  Future<int> insert(Budget budget) async {
    final db = await _db.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<Budget?> findById(int id) async {
    final db = await _db.database;
    final result =
    await db.query('budgets', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  Future<List<Budget>> findByUser(int userId) async {
    final db = await _db.database;
    final result = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map(Budget.fromMap).toList();
  }

  Future<Budget?> findByUserAndCategory(int userId, int categoryId) async
  {
    final db = await _db.database;
    final result = await db.query(
      'budgets',
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  Future<int> update(Budget budget) async {
    final db = await _db.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}