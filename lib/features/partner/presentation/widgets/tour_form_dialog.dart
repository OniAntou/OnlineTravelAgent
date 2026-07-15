import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tours/domain/tour_package.dart';
import 'partner_form_field.dart';

class TourFormDialog extends StatefulWidget {
  final TourPackage? tour;
  const TourFormDialog({super.key, this.tour});

  @override
  State<TourFormDialog> createState() => _TourFormDialogState();
}

class _TourFormDialogState extends State<TourFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _departureCtrl;
  late final TextEditingController _destinationsCtrl;
  late final TextEditingController _includesCtrl;

  bool get isEditing => widget.tour != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tour;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _priceCtrl = TextEditingController(
      text: t != null ? t.price.toInt().toString() : '',
    );
    _durationCtrl = TextEditingController(text: t?.duration ?? '');
    _departureCtrl = TextEditingController(text: t?.departure ?? '');
    _destinationsCtrl = TextEditingController(
      text: t?.destinations.join(', ') ?? '',
    );
    _includesCtrl = TextEditingController(text: t?.includes.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _departureCtrl.dispose();
    _destinationsCtrl.dispose();
    _includesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Sửa tour' : 'Thêm tour mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PartnerFormField(
                controller: _nameCtrl,
                label: 'Tên tour',
                isRequired: true,
              ),
              PartnerFormField(
                controller: _descCtrl,
                label: 'Mô tả',
                maxLines: 3,
              ),
              PartnerFormField(
                controller: _priceCtrl,
                label: 'Giá (VND)',
                keyboard: TextInputType.number,
                isRequired: true,
              ),
              PartnerFormField(
                controller: _durationCtrl,
                label: 'Thời lượng (VD: 3N2Đ)',
              ),
              PartnerFormField(
                controller: _departureCtrl,
                label: 'Điểm khởi hành (VD: TP.HCM)',
              ),
              PartnerFormField(
                controller: _destinationsCtrl,
                label: 'Điểm đến (phân cách bằng dấu phẩy)',
              ),
              PartnerFormField(
                controller: _includesCtrl,
                label: 'Bao gồm (phân cách bằng dấu phẩy)',
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
              'description': _descCtrl.text.trim(),
              'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
              'duration': _durationCtrl.text.trim(),
              'departure': _departureCtrl.text.trim(),
              'destinations': _destinationsCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              'includes': _includesCtrl.text
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
