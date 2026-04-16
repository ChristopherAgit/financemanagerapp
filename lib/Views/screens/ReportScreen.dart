import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../Controllers/ReportController.dart';
import '../styles/app_colors.dart';

class ReportScreen extends StatefulWidget {
  final int userId;
  const ReportScreen({super.key, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final ReportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReportController(userId: widget.userId);
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reportes y Análisis')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return RefreshIndicator(
            color:     AppColors.accent,
            onRefresh: _controller.loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildKpiRow(),
                  const SizedBox(height: 16),

                  if (_controller.categoryReport.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildDonutChart(),
                    const SizedBox(height: 16),
                    _buildBarChart(),
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(),
                    const SizedBox(height: 16),
                    _buildExpenseList(),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'key': 'today', 'label': 'Hoy'},
      {'key': 'week',  'label': 'Semana'},
      {'key': 'month', 'label': 'Mes'},
      {'key': 'year',  'label': 'Año'},
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
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 9),
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

  Widget _buildKpiRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon:  Icons.account_balance_wallet_outlined,
                label: 'Total gastado',
                value: 'RD\$ ${_controller.formatAmount(_controller.totalSpent)}',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                icon:  Icons.receipt_long_outlined,
                label: 'Cantidad',
                value: '${_controller.totalCount} gastos',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon:  Icons.trending_up_outlined,
                label: 'Gasto promedio',
                value: 'RD\$ ${_controller.formatAmount(_controller.avgPerExpense)}',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                icon:  Icons.arrow_upward_outlined,
                label: 'Gasto mayor',
                value: 'RD\$ ${_controller.formatAmount(_controller.highestExpense)}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDonutChart() {
    final report = _controller.categoryReport;
    final total  = _controller.totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución por categoría',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              // Dona
              SizedBox(
                width:  160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 160),
                      painter: _DonutPainter(
                        data:  report,
                        total: total,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize:      10,
                            fontWeight:    FontWeight.w700,
                            color:         AppColors.mutedText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RD\$\n${_controller.formatAmount(total)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Leyenda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: report.asMap().entries.map((entry) {
                    final i     = entry.key;
                    final item  = entry.value;
                    final color = AppColors.chartColors[
                    i % AppColors.chartColors.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width:  12,
                            height: 12,
                            decoration: BoxDecoration(
                              color:         color,
                              borderRadius:  BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color:    AppColors.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(item.percentage * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final report = _controller.categoryReport;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativa de categorías',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),

          ...report.asMap().entries.map((entry) {
            final i     = entry.key;
            final item  = entry.value;
            final color = AppColors.chartColors[
            i % AppColors.chartColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w500,
                            color:      AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'RD\$ ${_controller.formatAmount(item.total)}',
                        style: const TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w700,
                          color:      AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:           item.percentage,
                      minHeight:       10,
                      backgroundColor: AppColors.borderColor,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.count} gasto${item.count != 1 ? 's' : ''}  •  ${(item.percentage * 100).toStringAsFixed(1)} %',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mutedText),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final report = _controller.categoryReport;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen por categoría',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),

          // Encabezado de tabla
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Categoría',
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'N°',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.borderColor),

          ...report.asMap().entries.map((entry) {
            final i     = entry.key;
            final item  = entry.value;
            final color = AppColors.chartColors[
            i % AppColors.chartColors.length];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      // Indicador de color
                      Container(
                        width:  10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:         color,
                          borderRadius:  BorderRadius.circular(2),
                        ),
                      ),
                      // Nombre
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w500,
                            color:      AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Total
                      Expanded(
                        flex: 2,
                        child: Text(
                          'RD\$ ${_controller.formatAmount(item.total)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w700,
                            color:      AppColors.darkText,
                          ),
                        ),
                      ),
                      // Cantidad
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.count}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            color:    AppColors.mutedText,
                          ),
                        ),
                      ),
                      // Porcentaje
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${(item.percentage * 100).toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.key < report.length - 1)
                  Container(
                    height: 1,
                    color: AppColors.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    final expenses = _controller.expenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detalle de gastos',
                style: TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w600,
                  color:      AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:         AppColors.accent.withOpacity(0.1),
                  borderRadius:  BorderRadius.circular(20),
                ),
                child: Text(
                  '${expenses.length}',
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...expenses.map((expense) {
            final catName =
            _controller.categoryName(expense.categoryId);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:         AppColors.background,
                borderRadius:  BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Ícono
                  Container(
                    width:  38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.accent,
                      size:  17,
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
                            fontSize:   13,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withOpacity(0.08),
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              child: Text(
                                catName,
                                style: const TextStyle(
                                  fontSize:   10,
                                  fontWeight: FontWeight.w500,
                                  color:      AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              expense.date.substring(0, 10),
                              style: const TextStyle(
                                fontSize: 11,
                                color:    AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Monto
                  Text(
                    'RD\$ ${_controller.formatAmount(expense.amount)}',
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.darkText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        children: const [
          Icon(Icons.bar_chart_outlined,
              size: 56, color: AppColors.lightText),
          SizedBox(height: 16),
          Text(
            'Sin datos para este periodo',
            style: TextStyle(
              fontSize:   15,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Registra gastos para ver tus reportes\ny análisis aquí.',
            style: TextStyle(
                color: AppColors.mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:         AppColors.surface,
      borderRadius:  BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderColor),
      boxShadow: [
        BoxShadow(
          color:      Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:         AppColors.surface,
        borderRadius:  BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color:         color.withOpacity(0.1),
              borderRadius:  BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize:   15,
              fontWeight: FontWeight.w700,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CategoryReport> data;
  final double               total;

  const _DonutPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = size.width / 2;
    const strokeWidth = 28.0;
    const gap         = 0.03;

    final paint = Paint()
      ..style      = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap  = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweep = data[i].percentage * 2 * math.pi - gap;
      if (sweep <= 0) continue;

      paint.color = AppColors.chartColors[
      i % AppColors.chartColors.length];

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