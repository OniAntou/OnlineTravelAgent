import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class BankTransferScreen extends ConsumerStatefulWidget {
  final double amount;
  final String tripId;
  final String? orderInfo;
  final VoidCallback? onConfirmed;

  const BankTransferScreen({
    super.key,
    required this.amount,
    required this.tripId,
    this.orderInfo,
    this.onConfirmed,
  });

  @override
  ConsumerState<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends ConsumerState<BankTransferScreen> {
  bool _isConfirmed = false;
  bool _isCopied = false;

  // Bank config — change these to your real account
  static const String bankName = 'Vietcombank';
  static const String bankBin = '970436';
  static const String accountNumber = '1234567890';
  static const String accountName = 'CONG TY ONLINE TRAVEL AGENT';

  String get _transferContent => 'OTT ${widget.tripId}';

  String get _vietQrPayload {
    final amount = widget.amount.round().toString();
    final info = _transferContent.toUpperCase();

    // Tag 00: Payload Format Indicator
    const tag00 = '000201';
    // Tag 01: Point of Initiation Method (12=dynamic)
    const tag01 = '010212';

    // Tag 38: Merchant Account Information (VietQR)
    const aid = 'A000000727';
    const serviceCode = 'QRIBFTTA';

    final sub00 = '00${_padLen(aid)}$aid';
    // Sub01: nested — BIN in sub00, account in sub01
    final sub01Inner = '00${_padLen(bankBin)}$bankBin' '01${_padLen(accountNumber)}$accountNumber';
    final sub01 = '01${_padLen(sub01Inner)}$sub01Inner';
    final sub02 = '02${_padLen(serviceCode)}$serviceCode';
    final merchantInfo = '$sub00$sub01$sub02';
    final tag38 = '38${_padLen(merchantInfo)}$merchantInfo';

    // Tag 53: Currency (VND)
    const tag53 = '5303704';
    // Tag 54: Amount
    final tag54 = '54${_padLen(amount)}$amount';
    // Tag 58: Country
    const tag58 = '5802VN';

    // Tag 62: Additional Data (sub 08 = purpose info)
    final sub62 = '08${_padLen(info)}$info';
    final tag62 = '62${_padLen(sub62)}$sub62';

    // Tag 63: CRC16-CCITT
    const tag63 = '6304';
    final payloadWithoutCrc = '$tag00$tag01$tag38$tag53$tag54$tag58$tag62$tag63';
    final crc = _crc16CCITT(payloadWithoutCrc);
    return '$payloadWithoutCrc$crc';
  }

  String _padLen(String s) => s.length.toString().padLeft(2, '0');

  String _crc16CCITT(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      crc ^= (data.codeUnitAt(i) << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép'),
        duration: Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _confirmPayment() {
    setState(() => _isConfirmed = true);
    widget.onConfirmed?.call();
  }

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
          onPressed: () => Navigator.pop(context, _isConfirmed),
        ),
        title: const Text(
          'Chuyển khoản ngân hàng',
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
                  if (_isConfirmed)
                    _buildSuccessBanner()
                  else
                    _buildPendingBanner(),

                  const SizedBox(height: 20),

                  _buildAmountCard(),

                  const SizedBox(height: 20),

                  _buildQrSection(),

                  const SizedBox(height: 20),

                  _buildBankInfoCard(),

                  const SizedBox(height: 20),

                  _buildInstructionCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            if (!_isConfirmed) _buildBottomBar(),
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
              'Quét mã QR hoặc chuyển khoản theo thông tin bên dưới. Nhấn "Đã chuyển khoản" khi hoàn tất.',
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
              'Đã ghi nhận chuyển khoản! Đơn hàng của bạn đang được xử lý.',
              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
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
          const Text('Số tiền cần chuyển', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            formatVND(widget.amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection() {
    return Center(
      child: Container(
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
              data: _vietQrPayload,
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
              'Quét mã QR bằng app ngân hàng',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ngân hàng', bankName),
          _buildInfoRow('Số tài khoản', accountNumber, copyable: true),
          _buildInfoRow('Chủ tài khoản', accountName),
          _buildInfoRow('Nội dung CK', _transferContent, copyable: true,
              highlight: true),
          _buildInfoRow('Số tiền', formatVND(widget.amount), highlight: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppTheme.primaryBlue : AppTheme.textBlack,
              ),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Icon(
                _isCopied ? Icons.check_circle : Icons.copy_rounded,
                size: 18,
                color: _isCopied ? Colors.green : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hướng dẫn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 8),
          _StepWidget(step: '1', text: 'Mở app ngân hàng → Quét mã QR hoặc chuyển khoản thủ công'),
          _StepWidget(step: '2', text: 'Nhập đúng nội dung chuyển khoản (OTT + mã đơn)'),
          _StepWidget(step: '3', text: 'Nhấn "Đã chuyển khoản" để xác nhận'),
        ],
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Đã chuyển khoản',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final String step;
  final String text;
  const _StepWidget({required this.step, required this.text});

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
            decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
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
