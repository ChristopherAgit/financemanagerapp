import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../widgets/header.dart';
import '../widgets/summary_card.dart';
import '../widgets/action_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeFilter = 'month';
  bool _showAlert = true;


  final List<Map<String, dynamic>> _expenses = [
    {
      'emoji': '🍔',
      'description': 'Almuerzo restaurante',
      'category': 'Comida',
      'date': 'Hoy, 1:30 PM',
      'amount': 850.00,
    },
    {
      'emoji': '🚌',
      'description': 'Transporte urbano',
      'category': 'Transporte',
      'date': 'Hoy, 8:00 AM',
      'amount': 120.00,
    },
    {
      'emoji': '🛒',
      'description': 'Supermercado Nacional',
      'category': 'Compras',
      'date': 'Ayer, 5:00 PM',
      'amount': 3200.00,
    },
    {
      'emoji': '💊',
      'description': 'Farmacia Carol',
      'category': 'Salud',
      'date': 'Ayer, 11:00 AM',
      'amount': 650.00,
    },
  ];

  final List<Map<String, dynamic>> _chartData = [
    {'name': 'Comida', 'emoji': '🍔', 'amount': 8500.0, 'color': Color(0xFF22C55E)},
    {'name': 'Transporte', 'emoji': '🚌', 'amount': 3200.0, 'color': Color(0xFF2563EB)},
    {'name': 'Compras', 'emoji': '🛒', 'amount': 12000.0, 'color': Color(0xFFF59E0B)},
    {'name': 'Salud', 'emoji': '💊', 'amount': 2800.0, 'color': Color(0xFFEF4444)},
    {'name': 'Otros', 'emoji': '📦', 'amount': 1500.0, 'color': Color(0xFF8B5CF6)},
  ];

  double get _totalAmount =>
      _chartData.fold(0, (sum, item) => sum + (item['amount'] as double));

  void _goToReports() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reportes próximamente')));
  }

  void _goToLimits() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Límites próximamente')));
  }

  void _goToCategories() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Categorías próximamente')));
  }

  void _registerExpense() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrar gasto próximamente')));
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(userName: widget.userName, onLogout: _logout),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (_showAlert) _buildLimitAlert(),

                    _buildFilters(),
                    const SizedBox(height: 20),

                    _buildSummarySection(),
                    const SizedBox(height: 24),

                    _buildContentGrid(),
                    const SizedBox(height: 24),

                    _buildQuickActions(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),

              Positioned(
                bottom: 24,
                right: 20,
                child: _buildFAB(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLimitAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFfef3c7), Color(0xFFfde68a)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            left: BorderSide(color: AppColors.warning, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Has alcanzado el 80% de tu límite mensual en Comida.',
              style: TextStyle(
                  color: Color(0xFF92400E), fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showAlert = false),
            child: const Text('×',
                style:
                TextStyle(fontSize: 22, color: Color(0xFF92400E))),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'key': 'month', 'label': 'Este Mes'},
      {'key': 'week', 'label': 'Esta Semana'},
      {'key': 'today', 'label': 'Hoy'},
    ];

    return Row(
      children: filters
          .map((f) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () => setState(() => _activeFilter = f['key']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: _activeFilter == f['key']
                  ? AppColors.primaryGradient
                  : null,
              color: _activeFilter == f['key']
                  ? null
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _activeFilter == f['key']
                    ? Colors.transparent
                    : AppColors.borderColor,
                width: 2,
              ),
            ),
            child: Text(
              f['label']!,
              style: TextStyle(
                color: _activeFilter == f['key']
                    ? Colors.white
                    : AppColors.lightText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        SummaryCard(
            emoji: '📅',
            label: 'Gastado Hoy',
            amount: 'RD\$ 970.00'),
        const SizedBox(height: 12),
        SummaryCard(
            emoji: '📊',
            label: 'Esta Semana',
            amount: 'RD\$ 4,820.00'),
        const SizedBox(height: 12),
        SummaryCard(
            emoji: '💰',
            label: 'Este Mes',
            amount: 'RD\$ 28,000.00'),
      ],
    );
  }

  Widget _buildContentGrid() {
    return Column(
      children: [

        _buildChartSection(),
        const SizedBox(height: 16),

        _buildRecentExpenses(),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gasto Total por Categoría',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),


          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _PieChartPainter(data: _chartData, total: _totalAmount),
                  ),

                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'RD\$\n${_formatAmount(_totalAmount)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),


          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _chartData.map((item) {
              final pct =
              ((item['amount'] as double) / _totalAmount * 100).toStringAsFixed(1);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['emoji']} ${item['name']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gastos Recientes',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _goToReports,
                child: const Text(
                  'Ver todos →',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._expenses.map((e) => _buildExpenseItem(e)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(expense['emoji'],
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense['category']} • ${expense['date']}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Text(
            'RD\$ ${_formatAmount(expense['amount'])}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.danger,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ActionCard(
              emoji: '📈', label: 'Reportes', onTap: _goToReports),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionCard(
              emoji: '🎯', label: 'Límites', onTap: _goToLimits),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionCard(
              emoji: '🏷️', label: 'Categorías', onTap: _goToCategories),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _registerExpense,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300)),
            SizedBox(width: 10),
            Text(
              'Registrar Gasto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return amount.toStringAsFixed(2);
  }
}


class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double total;

  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 38.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -1.5708;

    for (final item in data) {
      final sweep =
          (item['amount'] as double) / total * 2 * 3.14159265;
      paint.color = item['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}