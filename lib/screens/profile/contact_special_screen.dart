import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../utils/app_utils.dart';

class ContactSpecialScreen extends ConsumerStatefulWidget {
  const ContactSpecialScreen({super.key});

  @override
  ConsumerState<ContactSpecialScreen> createState() => _ContactSpecialScreenState();
}

class _ContactSpecialScreenState extends ConsumerState<ContactSpecialScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Fields
  String _selectedCategory = 'Đoàn lớn (100+ khách)';
  double _guests = 120;
  double _budget = 20000000;

  // Controllers
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Đoàn lớn (100+ khách)', 'icon': Icons.business_outlined},
    {'name': 'Team-building', 'icon': Icons.groups_outlined},
    {'name': 'Nghỉ dưỡng VIP', 'icon': Icons.diamond_outlined},
    {'name': 'Yêu cầu khác', 'icon': Icons.contact_support_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill profile info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider);
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderIntro(),
                      const SizedBox(height: 32),
                      _buildCategorySelector(),
                      const SizedBox(height: 32),
                      _buildGuestsSlider(),
                      const SizedBox(height: 24),
                      _buildBudgetSlider(),
                      const SizedBox(height: 32),
                      _buildContactFormFields(),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryBlue,
      elevation: 0,
      leadingWidth: 60,
      leading: Container(
        margin: const EdgeInsets.only(left: 20),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/phuquoc_image.jpg', // Using premium beach image
              fit: BoxFit.cover,
              cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bespoke Concierge',
                    style: TextStyle(
                      color: Color(0xFFFFD700), // Gold accent
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: [Shadow(blurRadius: 4)],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Thiết Kế Tour Chuyên Biệt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.diamond_rounded, color: AppTheme.primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dịch vụ VIP 24/7',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBlack),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cá nhân hoá trải nghiệm cho các đoàn khách lớn, hội nghị và nghỉ dưỡng cao cấp. Đội ngũ chuyên gia của chúng tôi sẽ thiết kế hành trình riêng theo đúng nhu cầu của bạn.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Category Selector ---
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ bạn đang tìm kiếm?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];
              final icon = cat['icon'] as IconData;
              final name = cat['name'] as String;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 32,
                        color: isSelected ? Colors.white : AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Guest Count Slider ---
  Widget _buildGuestsSlider() {
    final guestLabel = _guests.toInt() == 500 ? '500+ người' : '${_guests.toInt()} người';

    return _buildSliderCard(
      title: 'Số lượng khách dự kiến',
      valueLabel: guestLabel,
      icon: Icons.groups_rounded,
      slider: SliderTheme(
        data: SliderThemeData(
          trackHeight: 8,
          activeTrackColor: AppTheme.primaryBlue,
          inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          thumbColor: Colors.white,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
          overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
        child: Slider(
          value: _guests,
          min: 50,
          max: 500,
          divisions: 45,
          onChanged: (val) => setState(() => _guests = val),
        ),
      ),
      minText: '50 người',
      maxText: '500+',
    );
  }

  // --- Budget Slider ---
  Widget _buildBudgetSlider() {
    final budgetLabel = formatVND(_budget);

    return _buildSliderCard(
      title: 'Ngân sách linh hoạt',
      valueLabel: budgetLabel,
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Colors.green.shade600,
      bgColor: Colors.green.shade50,
      slider: SliderTheme(
        data: SliderThemeData(
          trackHeight: 8,
          activeTrackColor: Colors.green.shade500,
          inactiveTrackColor: Colors.green.shade100,
          thumbColor: Colors.white,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
          overlayColor: Colors.green.withValues(alpha: 0.2),
        ),
        child: Slider(
          value: _budget,
          min: 1000000,
          max: 50000000,
          divisions: 49,
          onChanged: (val) => setState(() => _budget = val),
        ),
      ),
      minText: '1 triệu',
      maxText: '50 triệu+',
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueLabel,
    required Widget slider,
    required String minText,
    required String maxText,
    required IconData icon,
    Color iconColor = AppTheme.primaryBlue,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor ?? AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  valueLabel,
                  style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          slider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minText, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(maxText, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Contact & Form fields ---
  Widget _buildContactFormFields() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind_rounded, color: AppTheme.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'Thông tin liên hệ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name Field
          _buildTextField(
            controller: _nameController,
            label: 'Họ và tên *',
            icon: Icons.person_rounded,
            validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 16),
          // Phone Field
          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại *',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Vui lòng nhập SĐT';
              if (val.length < 8) return 'SĐT không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email *',
            icon: Icons.mail_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Vui lòng nhập email';
              if (!val.contains('@')) return 'Email không đúng định dạng';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Company Field
          _buildTextField(
            controller: _orgController,
            label: 'Tên công ty / Tổ chức (Tuỳ chọn)',
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: 16),
          // Notes Field
          _buildTextField(
            controller: _notesController,
            label: 'Mô tả thêm yêu cầu đặc biệt của bạn...',
            icon: Icons.edit_note_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppTheme.textBlack, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8FAFC), // very light sleek blue-grey
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  // --- Submit action and API simulation ---
  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSubmitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0, // Using Container's beautiful shadow instead
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gửi Yêu Cầu Thiết Kế',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _handleSubmitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Display beautiful loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
              )
            ]
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3),
              SizedBox(height: 24),
              Text(
                'Đang thiết lập hồ sơ VIP...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textBlack),
              ),
            ],
          ),
        ),
      ),
    );

    // Generate random tracking number
    final reqId = 'SR-${Random().nextInt(9000) + 1000}';

    // Call travel provider to register a new tracker document
    final docTitle = 'Đoàn: ${_nameController.text} (${_guests.toInt()} khách)';
    final docDesc = 'Dịch vụ: $_selectedCategory. Ngân sách: ${formatVND(_budget)}. Mã số: #$reqId. Trạng thái: Đang xử lý.';

    try {
      final success = await ref.read(documentsProvider.notifier).addDocument(
            title: docTitle,
            description: docDesc,
            icon: 'business',
            color: _selectedCategory == 'Nghỉ dưỡng VIP' ? '#FF9800' : '#176FF2',
          );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          // Display beautiful wow-factor Success Dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.all(32),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 56),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Đăng Ký Thành Công!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.textBlack),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mã hồ sơ: #$reqId',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chuyên viên tư vấn cấp cao của chúng tôi đã tiếp nhận yêu cầu và sẽ liên hệ với bạn trong vòng 2 giờ làm việc.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext); // Close success dialog
                          Navigator.pop(context); // Pop current contact page back to profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text('Quay lại Hồ sơ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi xử lý yêu cầu. Vui lòng thử lại.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
