import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/flight.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/dialog_utils.dart';
import '../checkout/payment_method_screen.dart';

class FlightCheckoutScreen extends ConsumerStatefulWidget {
  final Flight flight;
  final String date;

  const FlightCheckoutScreen({
    super.key,
    required this.flight,
    required this.date,
  });

  @override
  ConsumerState<FlightCheckoutScreen> createState() =>
      _FlightCheckoutScreenState();
}

class _FlightCheckoutScreenState extends ConsumerState<FlightCheckoutScreen> {
  int _adults = 1;
  int _children = 0;
  bool _isBusinessClass = false;
  int _extraBaggage = 0; // 0, 15, 20 kg
  bool _isProcessing = false;

  double get _totalPrice {
    final basePrice = widget.flight.price.toDouble();
    final adultPrice = basePrice * _adults;
    final childPrice = basePrice * 0.75 * _children; // Children are 75%
    final classMultiplier = _isBusinessClass ? 2.0 : 1.0;

    double baggagePrice = 0;
    if (_extraBaggage == 15) baggagePrice = 20;
    if (_extraBaggage == 20) baggagePrice = 30;

    return (adultPrice + childPrice) * classMultiplier + baggagePrice;
  }

  void _navigateToPayment() async {
    if (!ref.read(authProvider).isLoggedIn) {
      showErrorSnackBar(context, 'Vui lòng đăng nhập để đặt!');
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (_adults < 1) {
      showErrorSnackBar(context, 'Phải có ít nhất 1 người lớn');
      return;
    }

    setState(() => _isProcessing = true);

    final String guestsStr =
        '$_adults Người lớn, $_children Trẻ em'
        '${_isBusinessClass ? ' (Thương gia)' : ' (Phổ thông)'}';

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            totalPrice: _totalPrice,
            onPaymentSuccess: () async {
              if (!mounted) return null;
              final notifier = ref.read(tripsProvider.notifier);
              return await notifier.bookFlight(
                flightId: widget.flight.id,
                date: widget.date,
                guests: guestsStr,
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
        title: const Text(
          'Thanh toán vé máy bay',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlightSummary(),
                const SizedBox(height: 28),
                _buildPassengerSection(),
                const SizedBox(height: 28),
                _buildClassOptions(),
                const SizedBox(height: 28),
                _buildBaggageOptions(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildBottomBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          widget.flight.airlineLogo,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.flight, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.flight.airline,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(height: 1, color: Colors.transparent), // Layout dummy
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            (constraints.constrainWidth() / 8).floor(),
                            (index) => const SizedBox(
                              width: 4,
                              height: 1.5,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeLocation(
                  widget.flight.departureTime,
                  widget.flight.departure,
                  CrossAxisAlignment.start,
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.flight.duration,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildTimeLocation(
                  widget.flight.arrivalTime,
                  widget.flight.arrival,
                  CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLocation(
    String time,
    String location,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành khách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              _buildCounterRow(
                title: 'Người lớn',
                subtitle: 'Từ 12 tuổi trở lên',
                value: _adults,
                onChanged: (val) {
                  if (val >= 1) setState(() => _adults = val);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
              _buildCounterRow(
                title: 'Trẻ em',
                subtitle: 'Dưới 12 tuổi',
                value: _children,
                onChanged: (val) {
                  if (val >= 0) setState(() => _children = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged(value - 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value > 0
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: value > 0 ? AppTheme.primaryBlue : Colors.grey,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hạng ghế',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isBusinessClass = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: !_isBusinessClass
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    border: Border.all(
                      color: !_isBusinessClass
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade300,
                      width: !_isBusinessClass ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: !_isBusinessClass
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_seat_rounded,
                        color: !_isBusinessClass
                            ? AppTheme.primaryBlue
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phổ thông',
                        style: TextStyle(
                          color: !_isBusinessClass
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Tiêu chuẩn',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isBusinessClass = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _isBusinessClass
                        ? const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isBusinessClass
                        ? null
                        : Colors.white.withValues(alpha: 0.5),
                    border: Border.all(
                      color: _isBusinessClass
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isBusinessClass
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_extra_rounded,
                        color: _isBusinessClass
                            ? const Color(0xFFFBBF24)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thương gia',
                        style: TextStyle(
                          color: _isBusinessClass
                              ? const Color(0xFFFBBF24)
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Giá x2',
                        style: TextStyle(
                          color: _isBusinessClass
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBaggageOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hành lý ký gửi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _buildBaggageOption('7kg Xách tay', 'Không ký gửi', 0, 0),
        const SizedBox(height: 12),
        _buildBaggageOption(
          'Mua thêm 15kg',
          'Phù hợp du lịch ngắn ngày',
          15,
          20,
        ),
        const SizedBox(height: 12),
        _buildBaggageOption('Mua thêm 20kg', 'Phù hợp chuyến đi xa', 20, 30),
      ],
    );
  }

  Widget _buildBaggageOption(
    String title,
    String subtitle,
    int value,
    int price,
  ) {
    final isSelected = _extraBaggage == value;
    return GestureDetector(
      onTap: () => setState(() => _extraBaggage = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.luggage_rounded,
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (price > 0)
              Text(
                '+${formatVND(price * 1000.0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  formatVND(_totalPrice),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : _navigateToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
