import 'package:flutter/cupertino.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/CategoryRepository.dart';
import '../Infraestructure/Repository/KeywordRepository.dart';
import '../Models/Category.dart';
import '../Models/Keyword.dart';

enum CategoryStatus { idle, loading, loaded, saving, saved, error }

class CategoryController extends ChangeNotifier {
  final CategoryRepository _categoryRepo;
  final KeywordRepository  _keywordRepo;

  CategoryController()
      : _categoryRepo = CategoryRepository(DatabaseHelper.instance),
        _keywordRepo  = KeywordRepository(DatabaseHelper.instance);

  CategoryStatus _status  = CategoryStatus.idle;
  List<Category> _categories = [];
  String? _errorMessage;

  CategoryStatus get status => _status;
  List<Category> get categories => _categories;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == CategoryStatus.loading;
  bool get isSaving  => _status == CategoryStatus.saving;

  List<Category> get defaultCategories =>
      _categories.where((c) => c.isDefault).toList();

  List<Category> get customCategories =>
      _categories.where((c) => !c.isDefault).toList();

  Future<void> loadCategories() async {
    _setStatus(CategoryStatus.loading);
    try {
      _categories = await _categoryRepo.findAll();
      _setStatus(CategoryStatus.loaded);
    } catch (_) {
      _setError('No se pudieron cargar las categorías.');
    }
  }

  Future<bool> saveCategory({
    required String name,
    required String color,
    required String rawKeywords,
  }) async {
    if (name.trim().isEmpty) {
      _setError('El nombre es obligatorio.');
      return false;
    }

    final existing = await _categoryRepo.findByName(name.trim());
    if (existing != null) {
      _setError('Ya existe una categoría con ese nombre.');
      return false;
    }

    _setStatus(CategoryStatus.saving);

    try {
      final categoryId = await _categoryRepo.insert(
        Category(name: name.trim(), color: color),
      );

      final keywords = rawKeywords
          .split(',')
          .map((k) => k.trim().toLowerCase())
          .where((k) => k.isNotEmpty)
          .toList();

      for (final kw in keywords) {
        if (!await _keywordRepo.exists(kw, categoryId)) {
          await _keywordRepo.insert(
            Keyword(keyword: kw, categoryId: categoryId),
          );
        }
      }

      await loadCategories();
      return true;
    } catch (_) {
      _setError('No se pudo guardar la categoría.');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      await _keywordRepo.deleteByCategory(categoryId);
      final rows = await _categoryRepo.delete(categoryId);
      if (rows == 0) {
        _setError('No se puede eliminar una categoría del sistema.');
        return false;
      }
      await loadCategories();
      return true;
    } catch (_) {
      _setError('Ocurrió un error al eliminar.');
      return false;
    }
  }

  void _setStatus(CategoryStatus s) {
    _status       = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = CategoryStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }
}