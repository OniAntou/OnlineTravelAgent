import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';

Future<void> showEditProfileSheet(BuildContext context, WidgetRef ref) async {
  final profile = ref.read(profileProvider);
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: profile.name);
  final emailController = TextEditingController(text: profile.email);

  try {
    bool isLoading = false;
    await showCustomBottomSheet(
      context: context,
      builder: (sheetContext, setState) {
        return Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(
                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                  ).hasMatch(value.trim())) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isLoading = true);

                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          ref
                              .read(profileProvider.notifier)
                              .updateFromAuth(name: name, email: email);

                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          showSuccessSnackBar(
                            sheetContext,
                            'Cập nhật hồ sơ thành công',
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } finally {
    nameController.dispose();
    emailController.dispose();
  }
}

Future<void> showAddDocumentSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String iconName,
  required String colorHex,
}) async {
  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  try {
    bool isLoading = false;
    await showCustomBottomSheet(
      context: context,
      builder: (sheetContext, setState) {
        return Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thêm giấy tờ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: const Icon(Icons.info_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập mô tả'
                    : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isLoading = true);

                          final ok = await ref
                              .read(documentsProvider.notifier)
                              .addDocument(
                                title: title,
                                description: descriptionController.text.trim(),
                                icon: iconName,
                                color: colorHex,
                              );

                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          if (ok) {
                            showSuccessSnackBar(
                              sheetContext,
                              'Đã thêm giấy tờ',
                            );
                          } else {
                            showErrorSnackBar(
                              sheetContext,
                              'Thêm giấy tờ thất bại',
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Thêm mới',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } finally {
    descriptionController.dispose();
  }
}
