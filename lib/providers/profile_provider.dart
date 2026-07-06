import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/document_item.dart';
import 'api_provider.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => const UserProfile(name: 'User', email: '');

  void updateFromAuth({required String name, required String email}) {
    state = UserProfile(name: name, email: email);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);

class DocumentsNotifier extends Notifier<List<DocumentItem>> {
  @override
  List<DocumentItem> build() => [];

  Future<bool> addDocument({
    required String title,
    required String description,
    String icon = 'description',
    String color = '#176FF2',
  }) async {
    try {
      final doc = await ref
          .read(apiProvider)
          .addDocument(
            title: title,
            description: description,
            icon: icon,
            color: color,
          );
      state = [doc, ...state];
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      await ref.read(apiProvider).deleteDocument(documentId);
      state = state.where((d) => d.id != documentId).toList();
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateFromBootstrap(List<DocumentItem> documents) {
    state = documents;
  }
}

final documentsProvider =
    NotifierProvider<DocumentsNotifier, List<DocumentItem>>(
      DocumentsNotifier.new,
    );
