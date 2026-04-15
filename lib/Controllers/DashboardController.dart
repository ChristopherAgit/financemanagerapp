import 'package:flutter/cupertino.dart';
import '../Infraestructure/Database/DatabaseHelper.dart';
import '../Infraestructure/Repository/BudgetRepository.dart';
import '../Infraestructure/Repository/ExpenseRepository.dart';
import '../Models/Budget.dart';
import '../Models/Expense.dart';

enum DashboardStatus { idle, loading, loaded, error }

class DashboardController extends ChangeNotifier {
  final int _userId;

  final ExpenseRepository  _expenseRepo;
  final BudgetRepository   _budgetRepo;

  DashboardController({required int userId}) : _userId = userId,
        _expenseRepo = ExpenseRepository(DatabaseHelper.instance),
        _budgetRepo  = BudgetRepository(DatabaseHelper.instance);

  DashboardStatus _status = DashboardStatus.idle;
  String _activeFilter = 'month';
  bool _showAlert = true;
  double _totalToday = 0;
  double _totalWeek  = 0;
  double  _totalMonth  = 0;
  List<Expense>  _recentExpenses = [];
  List<Map<String, dynamic>> _categoryTotals = [];
  String? _budgetAlert;
  DashboardStatus get status => _status;
  String get activeFilter => _activeFilter;
  bool  get showAlert => _showAlert;
  double get totalToday => _totalToday;
  double  get totalWeek  => _totalWeek;
  double get totalMonth => _totalMonth;
  List<Expense> get recentExpenses => _recentExpenses;
  List<Map<String, dynamic>> get categoryTotals => _categoryTotals;
  String?                    get budgetAlert  => _budgetAlert;
  bool get isLoading => _status == DashboardStatus.loading;

  Future<void> loadData() async {
    _status = DashboardStatus.loading;
    notifyListeners();

    try
    {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day)
          .toIso8601String();
      final weekStart = now
          .subtract(const Duration(days: 7))
          .toIso8601String();
      final monthStart = DateTime(now.year, now.month, 1)
          .toIso8601String();
      final end = now.toIso8601String();

      _totalToday = await _expenseRepo.sumByUser(_userId,
          from: todayStart, to: end);
      _totalWeek  = await _expenseRepo.sumByUser(_userId,
          from: weekStart, to: end);
      _totalMonth = await _expenseRepo.sumByUser(_userId,
          from: monthStart, to: end);

      final all = await _expenseRepo.findByUser(_userId);
      _recentExpenses = all.take(5).toList();

      final filterFrom = _resolveFilterFrom(now);
      _categoryTotals = await _expenseRepo.sumGroupedByCategory(
        _userId,
        from: filterFrom,
        to: end,
      );

      _budgetAlert = await _checkBudgetAlert(monthStart, end);
      _status = DashboardStatus.loaded;
    } catch (_) {
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }
  Future<void> setFilter(String filter) async {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    await loadData();
  }

  void dismissAlert() {
    _showAlert = false;
    notifyListeners();
  }

  String _resolveFilterFrom(DateTime now) {
    switch (_activeFilter) {
      case 'today':
        return DateTime(now.year, now.month, now.day).toIso8601String();
      case 'week':
        return now.subtract(const Duration(days: 7)).toIso8601String();
      default:
        return DateTime(now.year, now.month, 1).toIso8601String();
    }
  }

  Future<String?> _checkBudgetAlert(String from, String to) async {
    final budgets = await _budgetRepo.findByUser(_userId);

    for (final budget in budgets) {
      if (budget.period != BudgetPeriod.monthly) continue;

      final catRow = _categoryTotals.firstWhere(
            (r) => r['id'] == budget.categoryId,
        orElse: () => {},
      );
      if (catRow.isEmpty) continue;

      final spent = (catRow['total'] as num).toDouble();
      final pct   = spent / budget.amount * 100;

      if (pct >= 80) {
        return 'Has utilizado el ${pct.toStringAsFixed(0)} % '
            'de tu límite mensual en ${catRow['name']}.';
      }
    }
    return null;
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