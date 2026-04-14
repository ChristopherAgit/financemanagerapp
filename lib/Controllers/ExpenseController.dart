

import 'package:flutter/cupertino.dart';

import '../Application/ClassificationService.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/CategoryRepository.dart';
import '../Infraestructure/Repository/ExpenseRepository.dart';
import '../Models/Category.dart';
import '../Models/Expense.dart';

enum ExpenseStatus { idle, classifying, saving, saved, error }

class ExpenseController extends ChangeNotifier {
  final int _userId;

  final ExpenseRepository     _expenseRepo;
  final CategoryRepository    _categoryRepo;
  final ClassificationService _classifier;

  ExpenseController({required int userId})
      : _userId       = userId,
        _expenseRepo  = ExpenseRepository(DatabaseHelper.instance),
        _categoryRepo = CategoryRepository(DatabaseHelper.instance),
        _classifier   = ClassificationService(DatabaseHelper.instance);

  ExpenseStatus   _status            = ExpenseStatus.idle;
  List<Category>  _categories        = [];
  Category?       _suggestedCategory;
  Category?       _selectedCategory;
  String?         _errorMessage;

  ExpenseStatus  get status            => _status;
  List<Category> get categories        => _categories;
  Category?      get suggestedCategory => _suggestedCategory;
  Category?      get selectedCategory  => _selectedCategory;
  String?        get errorMessage      => _errorMessage;

  bool get isClassifying => _status == ExpenseStatus.classifying;
  bool get isSaving      => _status == ExpenseStatus.saving;

  Future<void> init() async {
    _categories = await _categoryRepo.findAll();
    notifyListeners();
  }

  Future<void> classify(String description) async {
    if (description.trim().isEmpty) {
      _suggestedCategory = null;
      _selectedCategory  = null;
      notifyListeners();
      return;
    }

    _status = ExpenseStatus.classifying;
    notifyListeners();

    final suggested = await _classifier.classify(description);

    _suggestedCategory = suggested;
    _selectedCategory ??= suggested;

    _status = ExpenseStatus.idle;
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<bool> saveExpense({
    required String description,
    required String rawAmount,
    String currency = 'DOP',
    String? notes,
  }) async {
    if (description.trim().isEmpty) {
      _setError('La descripción es obligatoria.');
      return false;
    }

    final amount = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _setError('Ingresa un monto válido.');
      return false;
    }

    if (_selectedCategory == null) {
      _setError('Selecciona una categoría.');
      return false;
    }

    _status = ExpenseStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      Expense base = Expense(
        userId:              _userId,
        description:         description.trim(),
        amount:              amount,
        currency:            currency,
        date:                DateTime.now().toIso8601String(),
        categoryId:          _selectedCategory!.id!,
        suggestedCategoryId: _suggestedCategory?.id,
        notes:               notes?.trim(),
      );

      if (_selectedCategory?.id != _suggestedCategory?.id) {
        base = await _classifier.applyManualCorrection(
          expense:       base,
          newCategoryId: _selectedCategory!.id!,
        );
      }

      await _expenseRepo.insert(base);

      _status = ExpenseStatus.saved;
      notifyListeners();
      return true;
    } catch (_) {
      _setError('No se pudo guardar el gasto. Intenta de nuevo.');
      return false;
    }
  }
  void resetForm() {
    _status            = ExpenseStatus.idle;
    _suggestedCategory = null;
    _selectedCategory  = null;
    _errorMessage      = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = ExpenseStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }
}