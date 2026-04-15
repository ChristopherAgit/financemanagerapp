import 'package:flutter/cupertino.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/BudgetRepository.dart';
import '../Infraestructure/Repository/CategoryRepository.dart';
import '../Infraestructure/Repository/ExpenseRepository.dart';
import '../Models/Budget.dart';
import '../Models/Category.dart';

enum BudgetStatus { idle, loading, loaded, saving, saved, error }

class BudgetItem {
  final Budget   budget;
  final Category category;
  final double   spent;

  const BudgetItem({
    required this.budget,
    required this.category,
    required this.spent,
  });

  double get percentage =>
      budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;

  double get remaining =>
      (budget.amount - spent).clamp(0.0, double.infinity);

  bool get isWarning  => percentage >= 0.8 && percentage < 1.0;
  bool get isExceeded => percentage >= 1.0;
}

class BudgetController extends ChangeNotifier {
  final int _userId;

  final BudgetRepository _budgetRepo;
  final CategoryRepository _categoryRepo;
  final ExpenseRepository _expenseRepo;

  BudgetController({required int userId})
      : _userId = userId,
        _budgetRepo   = BudgetRepository(DatabaseHelper.instance),
        _categoryRepo = CategoryRepository(DatabaseHelper.instance),
        _expenseRepo  = ExpenseRepository(DatabaseHelper.instance);

  BudgetStatus _status = BudgetStatus.idle;
  List<BudgetItem> _items = [];
  List<Category> _categories = [];
  String? _errorMessage;

  BudgetStatus get status => _status;
  List<BudgetItem> get items => _items;
  List<Category>   get categories => _categories;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == BudgetStatus.loading;
  bool get isSaving  => _status == BudgetStatus.saving;

  Future<void> loadData() async {
    _setStatus(BudgetStatus.loading);

    try {
      final now  = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
      final end = now.toIso8601String();

      final budgets = await _budgetRepo.findByUser(_userId);
      _categories = await _categoryRepo.findAll();

      final catTotals = await _expenseRepo.sumGroupedByCategory(
        _userId,
        from: monthStart,
        to:   end,
      );

      _items = budgets.map((b) {
        final cat = _categories.firstWhere(
              (c) => c.id == b.categoryId,
          orElse: () => Category(id: b.categoryId, name: 'Sin categoría'),
        );
        final catRow = catTotals.firstWhere(
              (r) => r['id'] == b.categoryId,
          orElse: () => {},
        );
        final spent = catRow.isEmpty
            ? 0.0
            : (catRow['total'] as num).toDouble();

        return BudgetItem(budget: b, category: cat, spent: spent);
      }).toList();

      _setStatus(BudgetStatus.loaded);
    } catch (_) {
      _setError('No se pudieron cargar los límites.');
    }
  }

  Future<bool> saveBudget({
    required int categoryId,
    required String rawAmount,
    required String period,
  }) async {
    final amount = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _setError('Ingresa un monto válido.');
      return false;
    }

    _setStatus(BudgetStatus.saving);

    try {
      final existing =
      await _budgetRepo.findByUserAndCategory(_userId, categoryId);

      if (existing != null) {
        await _budgetRepo.update(existing.copyWith(
          amount: amount,
          period: BudgetPeriodExtension.fromString(period),
        ));
      } else {
        await _budgetRepo.insert(Budget(
          userId:  _userId,
          categoryId: categoryId,
          amount: amount,
          period: BudgetPeriodExtension.fromString(period),
        ));
      }

      await loadData();
      return true;
    } catch (_) {
      _setError('No se pudo guardar el límite.');
      return false;
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      await _budgetRepo.delete(budgetId);
      await loadData();
    } catch (_) {
      _setError('No se pudo eliminar el límite.');
    }
  }

  void _setStatus(BudgetStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = BudgetStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  String formatAmount(double amount) {
    if (amount >= 1000) {
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }
}