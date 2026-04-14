
import '../../Models/Keyword.dart';
import '../Database/DatabaseHelper.dart';

class KeywordRepository {
  final DatabaseHelper _db;

  KeywordRepository(this._db);

  Future<int> insert(Keyword keyword) async {
    final db = await _db.database;
    return await db.insert('keywords', keyword.toMap());
  }

  Future<List<Keyword>> findAll() async {
    final db = await _db.database;
    final result = await db.query('keywords');
    return result.map(Keyword.fromMap).toList();
  }

  Future<List<Keyword>> findByCategory(int categoryId) async {
    final db = await _db.database;
    final result = await db.query(
      'keywords',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return result.map(Keyword.fromMap).toList();
  }

  Future<bool> exists(String keyword, int categoryId) async {
    final db = await _db.database;
    final result = await db.query(
      'keywords',
      where: 'keyword = ? AND category_id = ?',
      whereArgs: [keyword, categoryId],
    );
    return result.isNotEmpty;
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('keywords', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByCategory(int categoryId) async {
    final db = await _db.database;
    return await db.delete(
      'keywords',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }
}