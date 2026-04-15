import 'package:flutter/material.dart';
import '../../Controllers/CategoryController.dart';
import '../../Models/Category.dart';
import '../styles/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final CategoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryController();
    _controller.loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CategoryFormSheet(controller: _controller),
    ).then((_) => _controller.loadCategories());
  }

  void _confirmDelete(Category category) {
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Las categorías del sistema no se pueden eliminar.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Eliminar categoría',
          style: TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w600,
            color:      AppColors.darkText,
          ),
        ),
        content: Text(
          'Se eliminará "${category.name}" y sus palabras clave asociadas. Esta acción no se puede deshacer.',
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
              _controller.deleteCategory(category.id!);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.danger)),
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
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: _showAddSheet,
            tooltip: 'Nueva categoría',
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

          return RefreshIndicator(
            color:     AppColors.accent,
            onRefresh: _controller.loadCategories,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección del sistema
                _buildSectionHeader(
                  'Categorías del sistema',
                  _controller.defaultCategories.length,
                ),
                const SizedBox(height: 8),
                ..._controller.defaultCategories.map(
                      (c) => _CategoryTile(
                    category: c,
                    onDelete: () => _confirmDelete(c),
                  ),
                ),

                const SizedBox(height: 24),

                // Sección personalizadas
                _buildSectionHeader(
                  'Categorías personalizadas',
                  _controller.customCategories.length,
                ),
                const SizedBox(height: 8),

                if (_controller.customCategories.isEmpty)
                  _buildEmptyCustoms()
                else
                  ..._controller.customCategories.map(
                        (c) => _CategoryTile(
                      category: c,
                      onDelete: () => _confirmDelete(c),
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

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize:   15,
            fontWeight: FontWeight.w600,
            color:      AppColors.darkText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:         AppColors.accent.withOpacity(0.1),
            borderRadius:  BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCustoms() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:         AppColors.surface,
        borderRadius:  BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.label_off_outlined,
              size: 40, color: AppColors.lightText),
          const SizedBox(height: 12),
          const Text(
            'Sin categorías personalizadas',
            style: TextStyle(
                color: AppColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation:       0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon:  const Icon(Icons.add, size: 16),
            label: const Text('Crear categoría'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category     category;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:         AppColors.surface,
        borderRadius:  BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:         AppColors.accent.withOpacity(0.08),
              borderRadius:  BorderRadius.circular(8),
            ),
            child: const Icon(Icons.label_outline,
                color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.isDefault
                      ? 'Categoría del sistema'
                      : 'Personalizada',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          if (category.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:         AppColors.accent.withOpacity(0.08),
                borderRadius:  BorderRadius.circular(6),
              ),
              child: const Text(
                'Sistema',
                style: TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.w500,
                  color:      AppColors.accent,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.danger, size: 20),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
        ],
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final CategoryController controller;
  const _CategoryFormSheet({required this.controller});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _nameController     = TextEditingController();
  final _keywordsController = TextEditingController();
  String  _selectedColor    = '#2563EB';
  bool    _isSaving         = false;
  String? _error;

  static const List<Map<String, dynamic>> _palette = [
    {'hex': '#2563EB', 'color': Color(0xFF2563EB)},
    {'hex': '#059669', 'color': Color(0xFF059669)},
    {'hex': '#B45309', 'color': Color(0xFFB45309)},
    {'hex': '#DC2626', 'color': Color(0xFFDC2626)},
    {'hex': '#7C3AED', 'color': Color(0xFF7C3AED)},
    {'hex': '#0891B2', 'color': Color(0xFF0891B2)},
    {'hex': '#1B2A4A', 'color': Color(0xFF1B2A4A)},
    {'hex': '#6B7280', 'color': Color(0xFF6B7280)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _isSaving = true; _error = null; });

    final ok = await widget.controller.saveCategory(
      name:        _nameController.text,
      color:       _selectedColor,
      rawKeywords: _keywordsController.text,
    );

    if (ok && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isSaving = false;
        _error    = widget.controller.errorMessage;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
        borderSide:
        const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:   20,
        right:  20,
        top:    24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Título + cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva categoría',
                  style: TextStyle(
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

            // Nombre
            const Text(
              'Nombre',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                  color: AppColors.darkText, fontSize: 14),
              decoration: _inputDecoration(
                hint: 'Ej: Educación',
                icon: Icons.label_outline,
              ),
            ),
            const SizedBox(height: 16),

            // Color
            const Text(
              'Color',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      AppColors.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing:    10,
              runSpacing: 10,
              children: _palette.map((p) {
                final isSelected = _selectedColor == p['hex'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColor = p['hex']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width:  38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: p['color'] as Color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                          color: AppColors.darkText, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: (p['color'] as Color)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Palabras clave
            const Text(
              'Palabras clave',
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Separa las palabras con comas. El sistema las usará para clasificar gastos automáticamente.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keywordsController,
              maxLines:   3,
              style: const TextStyle(
                  color: AppColors.darkText, fontSize: 14),
              decoration: _inputDecoration(
                hint: 'Ej: universidad, libros, cursos, matrícula',
                icon: Icons.key_outlined,
              ),
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Botón guardar
            SizedBox(
              width:  double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation:       0,
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
                    : const Text(
                  'Crear categoría',
                  style: TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}