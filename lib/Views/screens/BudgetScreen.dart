import 'package:flutter/material.dart';
import '../../Controllers/BudgetController.dart';
import '../../Models/Budget.dart';
import '../styles/app_colors.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;
  const BudgetScreen({super.key, required this.userId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late final BudgetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BudgetController(userId: widget.userId);
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Abrir formulario en bottom sheet ────────────────────────────────────
  void _showForm([BudgetItem? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BudgetFormSheet(
        controller: _controller,
        existing:   existing,
      ),
    ).then((_) => _controller.loadData());
  }

  // ── Confirmar eliminación ────────────────────────────────────────────────
  void _confirmDelete(BudgetItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Eliminar límite',
          style: TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w600,
            color:      AppColors.darkText,
          ),
        ),
        content: Text(
          'Se eliminará el límite de "${item.category.name}". Esta acción no se puede deshacer.',
          style: const TextStyle(
              color: AppColors.mutedText, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteBudget(item.budget.id!);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Control de Límites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => _showForm(),
            tooltip: 'Agregar límite',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (_controller.items.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color:     AppColors.accent,
            onRefresh: _controller.loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildResumenHeader(),
                const SizedBox(height: 16),
                ..._controller.items.map(
                      (item) => _BudgetCard(
                    item:         item,
                    formatAmount: _controller.formatAmount,
                    onEdit:       () => _showForm(item),
                    onDelete:     () => _confirmDelete(item),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Cabecera de resumen ──────────────────────────────────────────────────
  Widget _buildResumenHeader() {
    final total    = _controller.items.length;
    final warnings = _controller.items.where((i) => i.isWarning).length;
    final exceeded = _controller.items.where((i) => i.isExceeded).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color:       Colors.black.withOpacity(0.04),
            blurRadius:  8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStat('$total',    'Activos',      AppColors.accent),
          _buildDivider(),
          _buildStat('$warnings', 'Advertencia',  AppColors.warning),
          _buildDivider(),
          _buildStat('$exceeded', 'Excedidos',    AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize:   22,
              fontWeight: FontWeight.w700,
              color:      color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: AppColors.borderColor);
  }

  // ── Estado vacío ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune_outlined,
                size: 56, color: AppColors.lightText),
            const SizedBox(height: 16),
            const Text(
              'Sin límites configurados',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w600,
                color:      AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega un límite mensual por categoría\npara controlar tus gastos.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation:       0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon:  const Icon(Icons.add, size: 18),
              label: const Text('Agregar límite'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de un límite ──────────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final BudgetItem                  item;
  final String Function(double)     formatAmount;
  final VoidCallback                onEdit;
  final VoidCallback                onDelete;

  const _BudgetCard({
    required this.item,
    required this.formatAmount,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusColor {
    if (item.isExceeded) return AppColors.danger;
    if (item.isWarning)  return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
          // Cabecera
          Row(
            children: [
              Container(
                width:  40,
                height: 40,
                decoration: BoxDecoration(
                  color:         _statusColor.withOpacity(0.1),
                  borderRadius:  BorderRadius.circular(8),
                ),
                child: Icon(Icons.label_outline,
                    color: _statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.name,
                      style: const TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.darkText,
                      ),
                    ),
                    Text(
                      item.budget.period == BudgetPeriod.monthly
                          ? 'Límite mensual'
                          : 'Límite semanal',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.mutedText, size: 20),
                onSelected: (v) {
                  if (v == 'edit')   onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit',
                      child: Text('Editar')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar',
                        style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           item.percentage,
              minHeight:       8,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gastado',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.mutedText)),
                  Text(
                    'RD\$ ${formatAmount(item.spent)}',
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      _statusColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Disponible',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.mutedText)),
                  Text(
                    'RD\$ ${formatAmount(item.remaining)}',
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Límite',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.mutedText)),
                  Text(
                    'RD\$ ${formatAmount(item.budget.amount)}',
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (item.isExceeded || item.isWarning) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:         _statusColor.withOpacity(0.08),
                borderRadius:  BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.isExceeded
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                    size:  13,
                    color: _statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.isExceeded
                        ? 'Límite superado'
                        : 'Cerca del límite  •  ${(item.percentage * 100).toStringAsFixed(0)} %',
                    style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w500,
                      color:      _statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetFormSheet extends StatefulWidget {
  final BudgetController _controller;
  final BudgetItem?       existing;

  const _BudgetFormSheet({
    required BudgetController controller,
    this.existing,
  }) : _controller = controller;

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _amountController = TextEditingController();
  int?    _selectedCategoryId;
  String  _selectedPeriod = 'monthly';
  bool    _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _selectedCategoryId = widget.existing!.budget.categoryId;
      _selectedPeriod     = widget.existing!.budget.period.value;
      _amountController.text =
          widget.existing!.budget.amount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) {
      setState(() => _error = 'Selecciona una categoría.');
      return;
    }
    setState(() { _isSaving = true; _error = null; });

    final ok = await widget._controller.saveBudget(
      categoryId: _selectedCategoryId!,
      rawAmount:  _amountController.text,
      period:     _selectedPeriod,
    );

    if (ok && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _error    = widget._controller.errorMessage;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText:  hint,
      hintStyle: const TextStyle(
          color: AppColors.lightText, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.mutedText, size: 18),
      filled:    true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left:   20,
        right:  20,
        top:    24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize:      MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Editar límite' : 'Nuevo límite de gasto',
                style: const TextStyle(
                  fontSize:   18,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.darkText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.mutedText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Categoría',
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color:         const Color(0xFFF9FAFB),
              borderRadius:  BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value:      _selectedCategoryId,
                isExpanded: true,
                hint: const Text('Selecciona una categoría',
                    style: TextStyle(
                        color: AppColors.lightText, fontSize: 14)),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.mutedText),
                items: widget._controller.categories.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.name,
                        style: const TextStyle(
                            color: AppColors.darkText, fontSize: 14)),
                  );
                }).toList(),
                onChanged: isEdit
                    ? null
                    : (v) => setState(() => _selectedCategoryId = v),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Monto límite (RD\$)',
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller:  _amountController,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true),
            style: const TextStyle(
                color: AppColors.darkText, fontSize: 14),
            decoration: _inputDecoration(
              hint: '0.00',
              icon: Icons.attach_money_outlined,
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Periodo',
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w600,
              color:      AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PeriodChip(
                label:    'Mensual',
                selected: _selectedPeriod == 'monthly',
                onTap: () =>
                    setState(() => _selectedPeriod = 'monthly'),
              ),
              const SizedBox(width: 10),
              _PeriodChip(
                label:    'Semanal',
                selected: _selectedPeriod == 'weekly',
                onTap: () =>
                    setState(() => _selectedPeriod = 'weekly'),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: AppColors.danger),
                const SizedBox(width: 6),
                Text(_error!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ],
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width:  double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor:
                AppColors.accent.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text(
                isEdit ? 'Actualizar' : 'Guardar límite',
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool  selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:  selected ? Colors.white : AppColors.mutedText,
            fontWeight: FontWeight.w600,
            fontSize:   13,
          ),
        ),
      ),
    );
  }
}