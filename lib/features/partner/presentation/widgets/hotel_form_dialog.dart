import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../hotels/domain/hotel.dart';
import 'partner_form_field.dart';

class HotelFormDialog extends StatefulWidget {
  final Hotel? hotel;
  const HotelFormDialog({super.key, this.hotel});

  @override
  State<HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _amenitiesCtrl;

  bool get isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _locationCtrl = TextEditingController(text: h?.location ?? '');
    _addressCtrl = TextEditingController(text: h?.address ?? '');
    _priceCtrl = TextEditingController(
      text: h != null ? h.priceFrom.toInt().toString() : '',
    );
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _amenitiesCtrl = TextEditingController(text: h?.amenities.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _amenitiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa khách sạn' : 'Thêm khách sạn mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PartnerFormField(
                controller: _nameCtrl,
                label: 'Tên khách sạn',
                isRequired: true,
              ),
              PartnerFormField(
                controller: _locationCtrl,
                label: 'Địa điểm (VD: Hà Nội)',
                isRequired: true,
              ),
              PartnerFormField(
                controller: _addressCtrl,
                label: 'Địa chỉ chi tiết',
              ),
              PartnerFormField(
                controller: _priceCtrl,
                label: 'Giá từ (VND/đêm)',
                keyboard: TextInputType.number,
              ),
              PartnerFormField(
                controller: _descCtrl,
                label: 'Mô tả',
                maxLines: 3,
              ),
              PartnerFormField(
                controller: _amenitiesCtrl,
                label: 'Tiện nghi (phân cách bằng dấu phẩy)',
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
            final data = <String, dynamic>{
              'name': _nameCtrl.text.trim(),
              'location': _locationCtrl.text.trim(),
              'address': _addressCtrl.text.trim(),
              'priceFrom': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'description': _descCtrl.text.trim(),
              'amenities': _amenitiesCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            };
            Navigator.pop(context, data);
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
