import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/guest_counter.dart';
import 'payment_method_screen.dart';
import 'widgets/summary_card.dart';
import 'widgets/transport_selection.dart';
import 'widgets/guide_option.dart';
import '../../utils/api_exception.dart';
import '../../utils/app_utils.dart';
import '../../providers/api_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const CheckoutScreen({super.key, required this.destination});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? _selectedDate;
  int _adults = 1;
  int _children = 0;
  bool _isVip = false;
  // For single-destination booking, guide is optional
  bool _includeGuide = false;
  static const double _guideFee = 50.0;
  String _selectedTransport = 'Tự túc';
  bool _isProcessing = false;

  final TextEditingController _promoController = TextEditingController();
  double _promoDiscount = 0.0;
  String? _promoError;
  String? _promoCode;
  double? _promoPercentage;
  double? _promoFixedAmount;

  void _recalcPromo() {
    if (_promoCode == null) return;
    if (_promoPercentage != null) {
      _promoDiscount = (_subtotal + _tax) * _promoPercentage! / 100;
    } else if (_promoFixedAmount != null) {
      _promoDiscount = _promoFixedAmount!;
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (_promoCode != null) _recalcPromo();
  }

  final Map<String, int> _transportPrices = {
    'Tự túc': 0,
    'Xe giường nằm': 20,
    'Tàu hoả': 35,
    'Máy bay': 100,
  };

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int get _basePrice => int.tryParse(widget.destination.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int get _totalGuests => _adults + _children;

  double get _subtotal {
    final double adultPrice = _basePrice.toDouble() * _adults;
    final double childPrice = _basePrice.toDouble() * 0.5 * _children;
    double sub = adultPrice + childPrice;
    if (_isVip) sub += 50 * _totalGuests;
    sub += _transportPrices[_selectedTransport]! * _totalGuests;
    if (_includeGuide) sub += _guideFee; // fixed guide fee for single-destination bookings
    return sub;
  }

  double get _tax => _subtotal * 0.1;

  double get _total => (_subtotal + _tax) - _promoDiscount;

  Future<void> _checkPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    setState(() { _promoError = null; });
    try {
      final api = ref.read(apiProvider);
      final result = await api.checkPromoCode(code);
      if (!mounted) return;
      setState(() {
        _promoCode = code;
        _promoPercentage = result['discountPercentage']?.toDouble();
        _promoFixedAmount = result['discountAmount']?.toDouble();
        _recalcPromo();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Áp dụng mã thành công!')));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _promoError = e.message; });
    } on NetworkException catch (e) {
      if (mounted) setState(() { _promoError = e.message; });
    } on TimeoutApiException catch (e) {
      if (mounted) setState(() { _promoError = e.message; });
    } catch (e) {
      if (mounted) setState(() { _promoError = getErrorMessage(e); });
    }
  }

  void _onConfirm() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày khởi hành')),
      );
      return;
    }
    if (_adults < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phải có ít nhất 1 người lớn')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Calculate end date based on duration (simple logic)
    int days = 2;
    final match = RegExp(r'^(\d+)N').firstMatch(widget.destination.duration);
    if (match != null) {
      days = int.tryParse(match.group(1) ?? '2') ?? 2;
    }
    final endDate = _selectedDate!.add(Duration(days: days));

    final dateString = '${_dateFormat.format(_selectedDate!)} - ${_dateFormat.format(endDate)}';
    
    final List<String> guestParts = [];
    if (_adults > 0) guestParts.add('$_adults Người lớn');
    if (_children > 0) guestParts.add('$_children Trẻ em');
    final guestString = '${guestParts.join(', ')} ($_selectedTransport)';

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            totalPrice: _total,
            onPaymentSuccess: () async {
              if (!mounted) return null;
              return await ref.read(tripsProvider.notifier).bookTrip(
                destinationId: widget.destination.id,
                date: dateString,
                guests: guestString,
                totalPrice: _includeGuide ? _total : null,
              );
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildDestinationCard(),
          const SizedBox(height: 24),
          _buildDateSelection(),
          const SizedBox(height: 24),
          _buildGuestSelection(),
          const SizedBox(height: 24),
          _buildRoomSelection(),
          const SizedBox(height: 24),
          TransportSelection(
            selectedTransport: _selectedTransport,
            onTransportSelected: (value) => setState(() => _selectedTransport = value),
          ),
          const SizedBox(height: 16),
          GuideOption(
            includeGuide: _includeGuide,
            guideFee: _guideFee,
            onGuideToggled: (value) => setState(() => _includeGuide = value),
          ),
          const SizedBox(height: 24),
          _buildPromoField(),
          const SizedBox(height: 24),
          SummaryCard(
            adults: _adults,
            children: _children,
            basePrice: _basePrice,
            isVip: _isVip,
            totalGuests: _totalGuests,
            selectedTransport: _selectedTransport,
            transportPrices: _transportPrices,
            subtotal: _subtotal,
            tax: _tax,
            promoDiscount: _promoDiscount,
            total: _total,
          ),
          const SizedBox(height: 32),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.destination.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              cacheWidth: (80 * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destination.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.destination.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.destination.duration,
                    style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ngày khởi hành', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null ? 'Chọn ngày đi' : _dateFormat.format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                    fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hành khách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildGuestRow('Người lớn', 'Từ 12 tuổi', _adults, 1, (val) {
                if (val >= 1) setState(() => _adults = val);
              }),
              const Divider(height: 32),
              _buildGuestRow('Trẻ em', 'Dưới 12 tuổi', _children, 0, (val) {
                if (val >= 0) setState(() => _children = val);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestRow(String title, String subtitle, int count, int min, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        GuestCounter(value: count, min: min, onChanged: onChanged),
      ],
    );
  }

  Widget _buildRoomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loại dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildServiceOption('Standard', false),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildServiceOption('VIP (+${formatVND(50)}/người)', true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceOption(String title, bool isVipOption) {
    final isSelected = _isVip == isVipOption;
    return InkWell(
      onTap: () => setState(() => _isVip = isVipOption),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mã giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                decoration: InputDecoration(
                  hintText: 'Nhập mã giảm giá...',
                  errorText: _promoError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _checkPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text('Áp dụng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Xác nhận & Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
