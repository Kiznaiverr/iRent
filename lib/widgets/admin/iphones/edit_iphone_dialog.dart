import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/iphone_model.dart';
import '../../../providers/admin_provider.dart';

class EditIPhoneDialog extends ConsumerStatefulWidget {
  final IPhoneModel iphone;

  const EditIPhoneDialog({super.key, required this.iphone});

  static Future<void> show(BuildContext context, IPhoneModel iphone) {
    return showDialog(
      context: context,
      builder: (context) => EditIPhoneDialog(iphone: iphone),
    );
  }

  @override
  ConsumerState<EditIPhoneDialog> createState() => _EditIPhoneDialogState();
}

class _EditIPhoneDialogState extends ConsumerState<EditIPhoneDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _specsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.iphone.name);
    _priceController = TextEditingController(
      text: widget.iphone.pricePerDay.toString(),
    );
    _specsController = TextEditingController(text: widget.iphone.specs);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _specsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final specs = _specsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = await ref
        .read(adminProvider.notifier)
        .updateIPhone(widget.iphone.id, {
          'name': _nameController.text,
          'price_per_day': int.parse(_priceController.text),
          'specs': specs.join(', '),
        });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B9FE8).withValues(alpha: 0.15),
                  const Color(0xFF8AB4F8).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Color(0xFF6B9FE8),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Edit iPhone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(controller: _nameController, label: 'Nama iPhone'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _priceController,
              label: 'Harga per Hari',
              prefixText: 'Rp ',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _specsController,
              label: 'Spesifikasi',
              helperText: 'Pisahkan dengan koma',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixText: prefixText,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B9FE8), width: 2),
        ),
      ),
    );
  }
}
