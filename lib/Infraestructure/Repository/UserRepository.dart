import '../../Models/User.dart';
import '../Database/DatabaseHelper.dart';


class UserRepository {
  final DatabaseHelper _db;

  UserRepository(this._db);

  Future<int> insert(User user) async {
    final db = await _db.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> findById(int id) async {
    final db = await _db.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> findByEmail(String email) async {
    final db = await _db.database;
    final result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<List<User>> findAll() async {
    final db = await _db.database;
    final result = await db.query('users', orderBy: 'name ASC');
    return result.map(User.fromMap).toList();
  }

  Future<int> update(User user) async {
    final db = await _db.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}