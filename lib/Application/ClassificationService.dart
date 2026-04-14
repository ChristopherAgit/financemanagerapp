
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/CategoryRepository.dart';
import '../Infraestructure/Repository/KeywordRepository.dart';
import '../Models/Category.dart';
import '../Models/Expense.dart';
import '../Models/Keyword.dart';

class ClassificationService {
  final DatabaseHelper _db;
  late final CategoryRepository _categoryRepo;
  late final KeywordRepository _keywordRepo;

  ClassificationService(this._db) {
    _categoryRepo = CategoryRepository(_db);
    _keywordRepo = KeywordRepository(_db);
  }

  static const Map<String, List<String>> _defaultKeywords = {
    'Comida': ['almuerzo', 'cena', 'desayuno', 'pizza', 'restaurante', 'comida',
      'burger', 'pollo', 'sushi', 'cafe', 'cafeteria', 'merienda',
      'delivery', 'uber eats', 'ifood', 'fria', 'empanada',
    ],
    'Transporte': ['uber', 'pasaje', 'combustible', 'gasolina', 'gas', 'taxi', 'metro',
      'autobus', 'bus', 'peaje', 'estacionamiento', 'bolt', 'indriver',
      'carros publicos',
    ],
    'Salud': ['farmacia', 'medicina', 'medico', 'doctor', 'clinica', 'hospital',
      'pastilla', 'consulta', 'laboratorio', 'vacuna', 'seguro medico',
      'odontologia', 'dentista',],
    'Compras': ['ropa', 'supermercado', 'tienda', 'zapatos', 'mercado', 'colmado',
      'super', 'plaza', 'mall', 'amazon', 'shein', 'online',
    ],
    'Entretenimiento': ['cine', 'netflix', 'spotify', 'juego', 'concierto', 'evento',
      'teatro', 'disney', 'streaming', 'youtube',
    ],
    'Servicios': ['electricidad', 'agua', 'internet', 'telefono', 'claro', 'altice',
      'edesur', 'edenorte', 'edeeste', 'luz', 'factura', 'wind',
    ],
    'Otros': [],
  };

  Future<void> seedDefaultData() async {
    for (final entry in _defaultKeywords.entries) {
      // Crear categoría si no existe
      Category? cat = await _categoryRepo.findByName(entry.key);
      if (cat == null) {
        final id = await _categoryRepo.insert(Category(
          name: entry.key,
          isDefault: true,
        ));
        cat = Category(id: id, name: entry.key, isDefault: true);
      }
      for (final kw in entry.value) {
        if (!await _keywordRepo.exists(kw, cat.id!)) {
          await _keywordRepo.insert(
              Keyword(keyword: kw, categoryId: cat.id!));
        }
      }
    }
  }

  Future<Category> classify(String description) async {
    if (description.trim().isEmpty) return _fallback();

    final normalized = _normalize(description);
    final db = await _db.database;

    final rows = await db.rawQuery('''
    SELECT k.keyword, c.id, c.name, c.icon, c.color, c.is_default
      FROM keywords k
      JOIN categories c ON k.category_id = c.id''');

    for (final row in rows) {
      final kw = _normalize(row['keyword'] as String);
      if (normalized.contains(kw)) {
        return Category(
          id: row['id'] as int,
          name: row['name'] as String,
          icon: row['icon'] as String?,
          color: row['color'] as String?,
          isDefault: row['is_default'] == 1,
        );
      }
    }
    return _fallback();
  }

  Future<Expense> applyManualCorrection({
    required Expense expense,
    required int newCategoryId,
    bool learnFromCorrection = true,
  }) async {
    final wasCorrected = newCategoryId != expense.suggestedCategoryId;

    if (learnFromCorrection && wasCorrected) {
      await _learnKeyword(expense.description, newCategoryId);
    }

    return expense.copyWith(
      categoryId: newCategoryId,
      wasCorrected: wasCorrected,
    );
  }

  Future<void> _learnKeyword(String description, int categoryId) async {
    final words = _normalize(description)
        .split(' ')
        .where((w) => w.length > 3)
        .toList();

    if (words.isEmpty) return;

    final newKw = words.first;
    if (!await _keywordRepo.exists(newKw, categoryId)) {
      await _keywordRepo.insert(
          Keyword(keyword: newKw, categoryId: categoryId));
    }
  }

  Future<Category> _fallback() async {
    final cat = await _categoryRepo.findByName('Otros');
    return cat ?? const Category(name: 'Otros');
  }

  String _normalize(String text) => text
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n');
}