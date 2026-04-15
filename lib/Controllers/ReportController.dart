import 'package:flutter/cupertino.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/ExpenseRepository.dart';
import '../Infraestructure/Repository/CategoryRepository.dart';
import '../Models/Expense.dart';
import '../Models/Category.dart';

enum ReportStatus { idle, loading, loaded, error }

class CategoryReport {
  final int categoryId;
  final String name;
  final double total;
  final int count;
  final double percentage;

  const CategoryReport({
    required this.categoryId,
    required this.name,
    required this.total,
    required this.count,
    required this.percentage,
  });
}

class ReportController extends ChangeNotifier {
  final int _userId;

  final ExpenseRepository  _expenseRepo;
  final CategoryRepository _categoryRepo;

  ReportController({required int userId})
      : _userId = userId,
        _expenseRepo  = ExpenseRepository(DatabaseHelper.instance),
        _categoryRepo = CategoryRepository(DatabaseHelper.instance);

  ReportStatus  _status = ReportStatus.idle;
  String _activeFilter = 'month';
  List<Expense> _expenses = [];
  List<CategoryReport> _categoryReport = [];
  List<Category> _categories = [];
  double _totalSpent  = 0;
  int  _totalCount     = 0;
  double _avgPerExpense  = 0;
  double _highestExpense = 0;
  String? _errorMessage;

  ReportStatus get status => _status;
  String  get activeFilter => _activeFilter;
  List<Expense> get expenses  => _expenses;
  List<CategoryReport> get categoryReport => _categoryReport;
  List<Category> get categories => _categories;
  double get totalSpent => _totalSpent;
  int get totalCount => _totalCount;
  double get avgPerExpense  => _avgPerExpense;
  double get highestExpense => _highestExpense;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ReportStatus.loading;

  Future<void> loadData() async {
    _setStatus(ReportStatus.loading);

    try {
      final now  = DateTime.now();
      final from = _resolveFrom(now);
      final to = now.toIso8601String();

      _categories = await _categoryRepo.findAll();
      _expenses = await _expenseRepo.findByDateRange(_userId, from, to);

      _totalSpent = _expenses.fold(0, (s, e) => s + e.amount);
      _totalCount =  _expenses.length;
      _avgPerExpense = _totalCount > 0 ? _totalSpent / _totalCount : 0;
      _highestExpense = _expenses.isEmpty
          ? 0
          : _expenses
          .map((e) => e.amount)
          .reduce((a, b) => a > b ? a : b);

      final Map<int, double> totals = {};
      final Map<int, int>    counts = {};

      for (final e in _expenses) {
        totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
        counts[e.categoryId] = (counts[e.categoryId] ?? 0) + 1;
      }

      _categoryReport = totals.entries.map((entry) {
        final cat = _categories.firstWhere(
              (c) => c.id == entry.key,
          orElse: () => Category(id: entry.key, name: 'Sin categoría'),
        );
        return CategoryReport(
          categoryId: entry.key,
          name:       cat.name,
          total:      entry.value,
          count:      counts[entry.key] ?? 0,
          percentage: _totalSpent > 0 ? entry.value / _totalSpent : 0,
        );
      }).toList()
        ..sort((a, b) => b.total.compareTo(a.total));

      _setStatus(ReportStatus.loaded);
    } catch (_) {
      _setError('No se pudieron cargar los reportes.');
    }
  }

  Future<void> setFilter(String filter) async {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    await loadData();
  }

  String categoryName(int categoryId) {
    return _categories
        .firstWhere(
          (c) => c.id == categoryId,
      orElse: () => const Category(name: 'Sin categoría'),
    )
        .name;
  }

  String _resolveFrom(DateTime now) {
    switch (_activeFilter) {
      case 'today':
        return DateTime(now.year, now.month, now.day).toIso8601String();
      case 'week':
        return now.subtract(const Duration(days: 7)).toIso8601String();
      case 'year':
        return DateTime(now.year, 1, 1).toIso8601String();
      default:
        return DateTime(now.year, now.month, 1).toIso8601String();
    }
  }

  void _setStatus(ReportStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = ReportStatus.error;
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