import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finanzas_personales.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Activar foreign keys en SQLite
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE users (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        email      TEXT    UNIQUE NOT NULL,
        currency   TEXT    NOT NULL DEFAULT 'DOP',
        created_at TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL UNIQUE,
        icon       TEXT,
        color      TEXT,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE keywords (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword     TEXT    NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id               INTEGER NOT NULL,
        description           TEXT    NOT NULL,
        amount                REAL    NOT NULL,
        currency              TEXT    NOT NULL DEFAULT 'DOP',
        amount_converted      REAL,
        date                  TEXT    NOT NULL DEFAULT (datetime('now')),
        category_id           INTEGER NOT NULL,
        suggested_category_id INTEGER,
        was_corrected         INTEGER NOT NULL DEFAULT 0,
        notes                 TEXT,
        created_at            TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id)                REFERENCES users(id),
        FOREIGN KEY (category_id)            REFERENCES categories(id),
        FOREIGN KEY (suggested_category_id)  REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount      REAL    NOT NULL,
        period      TEXT    NOT NULL DEFAULT 'monthly',
        created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id)     REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE exchange_rates (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        from_currency TEXT NOT NULL,
        to_currency   TEXT NOT NULL,
        rate          REAL NOT NULL,
        fetched_at    TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
  }
}