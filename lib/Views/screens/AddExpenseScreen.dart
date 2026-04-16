import 'dart:async';
import 'package:flutter/material.dart';
import '../../Controllers/ExpenseController.dart';
import '../styles/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  final int userId;
  const AddExpenseScreen({super.key, required this.userId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descController   = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController  = TextEditingController();

  Timer? _debounce;
  late final ExpenseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpenseController(userId: widget.userId);
    _controller.init();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _descController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onDescriptionChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
          () => _controller.classify(value),
    );
  }

  Future<void> _save() async
  {
    final saved = await _controller.saveExpense(
      description: _descController.text,
      rawAmount: _amountController.text,
      notes: _notesController.text,
    );

    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto registrado correctamente.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.darkText, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Gasto',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildLabel('Descripción'),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  onChanged: _onDescriptionChanged,
                  style: const TextStyle(
                      color: AppColors.darkText, fontSize: 14),
                  decoration: _inputDecoration(
                    hint: 'Ej: Almuerzo en restaurante',
                    icon: Icons.edit_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Monto (RD\$)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: const TextStyle(
                      color: AppColors.darkText, fontSize: 14),
                  decoration: _inputDecoration(
                    hint: '0.00',
                    icon: Icons.attach_money_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                if (_controller.isClassifying)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Clasificando descripción...',
                          style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                if (_controller.suggestedCategory != null &&
                    !_controller.isClassifying) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_outlined,
                          size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Sugerido: ${_controller.suggestedCategory!.name}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                _buildLabel('Categoría'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border:
                    Border.all(color: AppColors.borderColor),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: _controller.selectedCategory,
                      isExpanded: true,
                      hint: const Text(
                        'Selecciona una categoría',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 14),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.mutedText),
                      items: _controller.categories
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c.name,
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (cat) {
                        if (cat != null) {
                          _controller.selectCategory(cat);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Notas (opcional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(
                      color: AppColors.darkText, fontSize: 14),
                  decoration: _inputDecoration(
                    hint: 'Agrega un comentario...',
                    icon: Icons.notes_outlined,
                  ),
                ),
                const SizedBox(height: 24),

                if (_controller.status == ExpenseStatus.error &&
                    _controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Text(
                          _controller.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _controller.isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor:
                      AppColors.accent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _controller.isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Guardar Gasto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: AppColors.lightText, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.mutedText, size: 18),
      filled: true,
      fillColor: AppColors.inputFill,
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
        borderSide:
        const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}