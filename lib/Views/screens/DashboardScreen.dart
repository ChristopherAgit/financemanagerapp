import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Controllers/DashboardController.dart';
import '../../Infraestructure/Database/DatabaseHelper.dart';
import '../../Models/Expense.dart';
import '../styles/app_colors.dart';
import '../widgets/action_card.dart';
import '../widgets/header.dart';
import '../widgets/summary_card.dart';
import 'AddExpenseScreen.dart';
import 'BudgetScreen.dart';
import 'CategoryScreen.dart';
import 'LoginScreen.dart';
import 'ReportScreen.dart';


class DashboardScreen extends StatefulWidget {final int userId;
  final String userName;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(userId: widget.userId);
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(userId: widget.userId),
      ),
    );
    _controller.loadData();
  }

  void _goToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(userId: widget.userId),
      ),
    );
  }

  void _goToLimits() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetScreen(userId: widget.userId),
      ),
    ).then((_) => _controller.loadData());
  }

  void _goToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryScreen()),
    ).then((_) => _controller.loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
          userName: widget.userName, onLogout: _logout),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.accent,
                onRefresh: _controller.loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (_controller.showAlert &&
                          _controller.budgetAlert != null)
                        _buildAlert(),

                      _buildFilters(),
                      const SizedBox(height: 20),

                      _buildSummary(),
                      const SizedBox(height: 24),

                      _buildChart(),
                      const SizedBox(height: 16),

                      _buildRecentExpenses(),
                      const SizedBox(height: 24),

                      _buildQuickActions(),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 24,
                right: 20,
                child: _buildFAB(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border:
        Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _controller.budgetAlert!,
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _controller.dismissAlert,
            child: const Icon(Icons.close,
                size: 16, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'key': 'month', 'label': 'Este Mes'},
      {'key': 'week',  'label': 'Esta Semana'},
      {'key': 'today', 'label': 'Hoy'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = _controller.activeFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _controller.setFilter(f['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accent
                        : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                    fontSize:   13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        SummaryCard(
          icon: Icons.today_outlined,
          label: 'Gastado Hoy',
          amount:
          'RD\$ ${_controller.formatAmount(_controller.totalToday)}',
        ),
        const SizedBox(height: 10),
        SummaryCard(
          icon: Icons.date_range_outlined,
          label: 'Esta Semana',
          amount:
          'RD\$ ${_controller.formatAmount(_controller.totalWeek)}',
        ),
        const SizedBox(height: 10),
        SummaryCard(
          icon: Icons.calendar_month_outlined,
          label: 'Este Mes',
          amount:
          'RD\$ ${_controller.formatAmount(_controller.totalMonth)}',
        ),
      ],
    );
  }

  Widget _buildChart() {
    final totals = _controller.categoryTotals;
    final total  = totals.fold<double>(
        0, (s, r) => s + (r['total'] as num).toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gasto por Categoría',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          if (totals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Sin datos para el periodo seleccionado.',
                  style: TextStyle(
                      color: AppColors.mutedText, fontSize: 13),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _DonutPainter(
                          data: totals, total: total),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RD\$\n${_controller.formatAmount(total)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(totals, total),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(
      List<Map<String, dynamic>> totals, double total) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
      ),
      itemCount: totals.length,
      itemBuilder: (_, i) {
        final row   = totals[i];
        final color =
        AppColors.chartColors[i % AppColors.chartColors.length];
        final pct   = total > 0
            ? ((row['total'] as num) / total * 100)
            .toStringAsFixed(1)
            : '0.0';

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row['name'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$pct %',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentExpenses() {
    final expenses = _controller.recentExpenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gastos Recientes',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _goToReports,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No hay gastos registrados.',
                  style: TextStyle(
                      color: AppColors.mutedText, fontSize: 13),
                ),
              ),
            )
          else
            ...expenses.map(_buildExpenseRow),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(Expense expense) {
    return FutureBuilder(
      future: DatabaseHelper.instance.database.then((db) => db.rawQuery(
        'SELECT name FROM categories WHERE id = ?',
        [expense.categoryId],
      )),
      builder: (context, snapshot) {
        final categoryName =
        snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!.first['name'] as String
            : '—';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$categoryName  •  ${expense.date.substring(0, 10)}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Text(
                'RD\$ ${_controller.formatAmount(expense.amount)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ActionCard(
            icon: Icons.bar_chart_outlined,
            label: 'Reportes',
            onTap: _goToReports,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ActionCard(
            icon: Icons.tune_outlined,
            label: 'Límites',
            onTap: _goToLimits,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ActionCard(
            icon: Icons.label_outline,
            label: 'Categorías',
            onTap: _goToCategories,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _openAddExpense,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Registrar Gasto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  const _DonutPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = size.width / 2;
    const strokeWidth = 30.0;
    const gap         = 0.025;

    final paint = Paint()
      ..style      = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap  = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < data.length; i++) {
      final sweep =
          (data[i]['total'] as num) / total * 2 * math.pi - gap;
      paint.color =
      AppColors.chartColors[i % AppColors.chartColors.length];
      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.data != data || old.total != total;
}