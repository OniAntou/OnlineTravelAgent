import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';
import '../domain/document_item.dart';
import '../../../data/services/api_provider.dart';
import 'package:flutter/foundation.dart';

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
    } catch (e, st) {
      debugPrint('Error adding document: $e\n$st');
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      await ref.read(apiProvider).deleteDocument(documentId);
      state = state.where((d) => d.id != documentId).toList();
      return true;
    } catch (e, st) {
      debugPrint('Error deleting document: $e\n$st');
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
