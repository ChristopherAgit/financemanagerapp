import '../../Models/Category.dart';
import '../Database/DatabaseHelper.dart';

class CategoryRepository {
  final DatabaseHelper _db;

  CategoryRepository(this._db);

  Future<int> insert(Category category) async {
    final db = await _db.database;
    return await db.insert('categories', category.toMap());
  }

  Future<Category?> findById(int id) async {
    final db = await _db.database;
    final result =
    await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Category.fromMap(result.first);
  }

  Future<Category?> findByName(String name) async {
    final db = await _db.database;
    final result =
    await db.query('categories', where: 'name = ?', whereArgs: [name]);
    if (result.isEmpty) return null;
    return Category.fromMap(result.first);
  }

  Future<List<Category>> findAll() async {
    final db = await _db.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map(Category.fromMap).toList();
  }

  Future<int> update(Category category) async {
    final db = await _db.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }
}