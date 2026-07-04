import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../utils/app_utils.dart';

class VnpayPaymentScreen extends ConsumerStatefulWidget {
  final String tripId;
  final double amount;
  final String paymentUrl;
  final String txnRef;

  const VnpayPaymentScreen({
    super.key,
    required this.tripId,
    required this.amount,
    required this.paymentUrl,
    required this.txnRef,
  });

  @override
  ConsumerState<VnpayPaymentScreen> createState() => _VnpayPaymentScreenState();
}

class _VnpayPaymentScreenState extends ConsumerState<VnpayPaymentScreen> {
  String _status = 'pending';
  bool _isChecking = false;
  Timer? _pollTimer;
  int _pollCount = 0;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _pollCount++;
      await _checkStatus();
      if (_pollCount >= 24 || _status == 'paid') {
        _pollTimer?.cancel();
      }
    });
  }

  Future<void> _checkStatus() async {
    try {
      final api = ref.read(apiProvider);
      final result = await api.checkPaymentStatus(widget.tripId);
      if (!mounted) return;
      final paymentStatus = result['paymentStatus'] as String? ?? 'pending';
      setState(() => _status = paymentStatus);
      if (paymentStatus == 'paid') {
        _pollTimer?.cancel();
      }
    } catch (_) {}
  }

  Future<void> _openVnpayGateway() async {
    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở cổng thanh toán VNPAY')),
      );
    }
  }

  Future<void> _checkNow() async {
    setState(() => _isChecking = true);
    await _checkStatus();
    setState(() => _isChecking = false);

    if (_status == 'paid' && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_status == 'failed' ? 'Thanh toán thất bại' : 'Chưa ghi nhận thanh toán. Vui lòng kiểm tra lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _status == 'paid';
    final isFailed = _status == 'failed';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Thanh toán VNPAY',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  if (isPaid)
                    _buildSuccessBanner()
                  else if (isFailed)
                    _buildFailedBanner()
                  else
                    _buildPendingBanner(),

                  const SizedBox(height: 24),

                  _buildAmountCard(),

                  const SizedBox(height: 24),

                  if (!isPaid && !isFailed) ...[
                    _buildQrCode(),
                    const SizedBox(height: 16),
                    _buildInstruction(),
                    const SizedBox(height: 24),
                    _buildOpenGatewayButton(),
                  ],

                  if (isPaid) ...[
                    const SizedBox(height: 16),
                    _buildBackToAppButton(),
                  ],

                  if (isFailed) ...[
                    const SizedBox(height: 16),
                    _buildRetryButton(),
                  ],
                ],
              ),
            ),

            if (!isPaid && !isFailed)
              _buildBottomCheckBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time, color: Color(0xFFF57C00)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đang chờ thanh toán. Vui lòng quét mã QR hoặc mở cổng VNPAY để thanh toán.',
              style: TextStyle(color: Color(0xFF795548), fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC2EED7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF07D95A), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thanh toán thành công! Chuyến đi của bạn đã được xác nhận.',
              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8C8C8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel, color: Color(0xFFE53E3E), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thanh toán thất bại. Vui lòng thử lại hoặc chọn phương thức khác.',
              style: TextStyle(color: Color(0xFFC53030), fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Text('Số tiền thanh toán', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            formatVND(widget.amount),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Mã GD: ${widget.txnRef}',
              style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    final qrData = widget.paymentUrl;
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primaryBlue,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quét mã QR bằng ứng dụng ngân hàng',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hướng dẫn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          _InstructionStep(step: '1', text: 'Quét mã QR bằng app ngân hàng hỗ trợ VNPAY'),
          _InstructionStep(step: '2', text: 'Hoặc nhấn "Mở cổng VNPAY" để thanh toán online'),
          _InstructionStep(step: '3', text: 'Sau khi thanh toán, nhấn "Đã thanh toán" để kiểm tra'),
        ],
      ),
    );
  }

  Widget _buildOpenGatewayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _openVnpayGateway,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF176FF2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Mở cổng VNPAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBackToAppButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Quay lại ứng dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() => _status = 'pending');
          _startPolling();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryBlue,
          side: const BorderSide(color: AppTheme.primaryBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.refresh),
        label: const Text('Thử lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomCheckBar() {
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isChecking ? null : _checkNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isChecking
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Đã thanh toán xong',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String step;
  final String text;
  const _InstructionStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
