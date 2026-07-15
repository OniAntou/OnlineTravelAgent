import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../hotels/domain/room.dart';
import 'partner_form_field.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room;
  const RoomFormDialog({super.key, this.room});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _capacityCtrl;

  bool get isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _priceCtrl = TextEditingController(
      text: r != null ? r.price.toInt().toString() : '',
    );
    _capacityCtrl = TextEditingController(
      text: r != null ? r.capacity.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa phòng' : 'Thêm phòng mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PartnerFormField(
                controller: _nameCtrl,
                label: 'Tên phòng',
                isRequired: true,
              ),
              PartnerFormField(controller: _descCtrl, label: 'Mô tả'),
              PartnerFormField(
                controller: _priceCtrl,
                label: 'Giá (VND/đêm)',
                keyboard: TextInputType.number,
                isRequired: true,
              ),
              PartnerFormField(
                controller: _capacityCtrl,
                label: 'Số khách tối đa',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'name': _nameCtrl.text.trim(),
              'description': _descCtrl.text.trim(),
              'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 1,
            });
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
