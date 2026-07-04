import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../utils/api_exception.dart';
import '../../utils/app_utils.dart';
import 'vnpay_payment_screen.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String type;
  final String? last4;
  final Widget logo;
  final String? description;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.last4,
    required this.logo,
    this.description,
  });
}

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final double totalPrice;
  final Future<String?> Function() onPaymentSuccess;
  final String initialMethodId;

  const PaymentMethodScreen({
    super.key,
    required this.totalPrice,
    required this.onPaymentSuccess,
    this.initialMethodId = 'mastercard',
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  late List<PaymentMethod> _methods;
  String _selectedMethodId = 'mastercard';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedMethodId = widget.initialMethodId;
    _methods = [
      PaymentMethod(
        id: 'vnpay',
        name: 'VNPAY',
        type: 'vnpay',
        description: 'Thanh toán qua mã QR, thẻ ATM, Visa',
        logo: _buildVnpayLogo(),
      ),
      PaymentMethod(
        id: 'momo',
        name: 'Ví MoMo',
        type: 'momo',
        description: 'Thanh toán qua ví MoMo',
        logo: _buildMomoLogo(),
      ),
      PaymentMethod(
        id: 'mastercard',
        name: 'Master Card',
        type: 'mastercard',
        description: 'Thanh toán qua thẻ quốc tế Mastercard',
        logo: _buildMasterCardLogo(),
      ),
      PaymentMethod(
        id: 'visa',
        name: 'Visa',
        type: 'visa',
        description: 'Thanh toán qua thẻ quốc tế Visa',
        logo: _buildVisaLogo(),
      ),
      PaymentMethod(
        id: 'bank_transfer',
        name: 'Chuyển khoản ngân hàng',
        type: 'bank_transfer',
        description: 'Chuyển khoản qua tài khoản ngân hàng',
        logo: _buildBankTransferLogo(),
      ),
      PaymentMethod(
        id: 'paypal',
        name: 'PayPal',
        type: 'paypal',
        description: 'Thanh toán quốc tế an toàn qua PayPal',
        logo: _buildPayPalLogo(),
      ),
      PaymentMethod(
        id: 'applepay',
        name: 'Apple Pay',
        type: 'applepay',
        description: 'Thanh toán nhanh qua ví Apple Pay',
        logo: _buildApplePayLogo(),
      ),
      PaymentMethod(
        id: 'cash',
        name: 'Tiền mặt',
        type: 'cash',
        description: 'Thanh toán trực tiếp khi khởi hành',
        logo: _buildCashLogo(),
      ),
    ];
  }

  // --- LOGO BUILDERS ---

  Widget _buildVnpayLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFDA251D),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VNPAY',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildMomoLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFA50064),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'MoMo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildBankTransferLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.account_balance,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMasterCardLogo() {
    return SizedBox(
      width: 44,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          color: Color(0xFF1A1F71),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPayPalLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD2E3FC)),
      ),
      alignment: Alignment.center,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          children: [
            TextSpan(text: 'Pay', style: TextStyle(color: Color(0xFF003087))),
            TextSpan(text: 'Pal', style: TextStyle(color: Color(0xFF0079C1))),
          ],
        ),
      ),
    );
  }

  Widget _buildApplePayLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, color: Colors.white, size: 14),
          SizedBox(width: 1),
          Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCashLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.payments_rounded, color: Color(0xFF4CAF50), size: 16),
    );
  }



  // --- ACTIONS ---

  void _handlePay() async {
    setState(() => _isProcessing = true);

    try {
      final selectedMethod = _methods.firstWhere((m) => m.id == _selectedMethodId);

      if (selectedMethod.type == 'vnpay' || selectedMethod.type == 'momo') {
        await _handleDigitalPayment(selectedMethod.type);
        return;
      }

      final tripId = await widget.onPaymentSuccess();
      setState(() => _isProcessing = false);
      if (tripId != null && mounted) {
        _showSuccessDialog(tripId);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thất bại, vui lòng thử lại')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } on TimeoutApiException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(getErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _handleDigitalPayment(String method) async {
    try {
      final tripId = await widget.onPaymentSuccess();
      if (tripId == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tạo đơn hàng')),
          );
        }
        return;
      }

      final api = ref.read(apiProvider);

      if (method == 'vnpay') {
        final result = await api.createVnpayPayment(
          tripId: tripId,
          amount: widget.totalPrice,
        );

        if (!mounted) return;
        setState(() => _isProcessing = false);

        final paymentUrl = result['paymentUrl'] as String;
        final txnRef = result['txnRef'] as String;

        final paymentSuccess = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => VnpayPaymentScreen(
              tripId: tripId,
              amount: widget.totalPrice,
              paymentUrl: paymentUrl,
              txnRef: txnRef,
            ),
          ),
        );

        if (paymentSuccess == true && mounted) {
          _showSuccessDialog(tripId);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán VNPAY chưa hoàn tất')),
          );
        }
      } else if (method == 'momo') {
        final result = await api.createMomoPayment(
          tripId: tripId,
          amount: widget.totalPrice,
        );

        if (!mounted) return;
        setState(() => _isProcessing = false);

        final payUrl = result['payUrl'] as String?;
        if (payUrl != null) {
          final uri = Uri.parse(payUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng thanh toán qua MoMo, sau đó quay lại kiểm tra')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể tạo thanh toán MoMo')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _showSuccessDialog(String tripId) {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeIn),
        );

        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(28),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC2EED7), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF07D95A), size: 64),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Đặt tour thành công!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedMethodId == 'cash'
                        ? 'Yêu cầu đặt tour của bạn đã được ghi nhận. Quý khách vui lòng chuẩn bị thanh toán bằng tiền mặt khi khởi hành chuyến đi.'
                        : 'Yêu cầu dịch vụ của bạn đã được xác nhận thành công. Bạn có thể kiểm tra chi tiết trong mục Chuyến đi.',
                    style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: const Text('Về Trang Chủ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.pushNamed(context, '/main');
                          },
                          child: const Text('Xem Chuyến Đi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Phương thức thanh toán',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      ..._methods.map(_buildMethodItem),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý thanh toán...',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textBlack),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMethodItem(PaymentMethod method) {
    final isSelected = _selectedMethodId == method.id;
    final selectedColor = method.type == 'vnpay'
        ? const Color(0xFFDA251D)
        : method.type == 'momo'
            ? const Color(0xFFA50064)
            : AppTheme.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedMethodId = method.id);
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? selectedColor : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: selectedColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Row(
              children: [
                method.logo,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textBlack),
                      ),
                      if (method.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          method.description!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                else
                  const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng thanh toán', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
              Text(
                formatVND(widget.totalPrice),
                style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _handlePay,
              child: const Text('Xác nhận & Thanh toán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
