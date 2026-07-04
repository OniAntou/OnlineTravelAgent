import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/models/document_item.dart';
import 'package:online_travel_agent/models/user_profile.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/providers/profile_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  late ProviderContainer container;
  late FakeTravelApiService fakeApi;

  setUp(() {
    fakeApi = FakeTravelApiService(secureStorage: FakeSecureStorage());
    container = ProviderContainer(
      overrides: [apiProvider.overrideWithValue(fakeApi)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileNotifier', () {
    test('initial state is default profile', () {
      final profile = container.read(profileProvider);
      expect(profile.name, 'User');
      expect(profile.email, '');
    });

    test('updateFromAuth updates name and email', () {
      container.read(profileProvider.notifier).updateFromAuth(
        name: 'Nguyen Van A',
        email: 'a@test.com',
      );
      final profile = container.read(profileProvider);
      expect(profile.name, 'Nguyen Van A');
      expect(profile.email, 'a@test.com');
    });

    test('updateFromAuth can be called multiple times', () {
      final notifier = container.read(profileProvider.notifier);
      notifier.updateFromAuth(name: 'First', email: 'first@test.com');
      notifier.updateFromAuth(name: 'Second', email: 'second@test.com');
      final profile = container.read(profileProvider);
      expect(profile.name, 'Second');
      expect(profile.email, 'second@test.com');
    });
  });

  group('DocumentsNotifier', () {
    test('initial state is empty list', () {
      final docs = container.read(documentsProvider);
      expect(docs, isEmpty);
    });

    test('addDocument adds to state', () async {
      final success = await container.read(documentsProvider.notifier).addDocument(
        title: 'Passport',
        description: 'My passport',
      );
      expect(success, true);

      final docs = container.read(documentsProvider);
      expect(docs.length, 1);
      expect(docs.first.title, 'Passport');
    });

    test('addDocument prepends to list', () async {
      final notifier = container.read(documentsProvider.notifier);
      await notifier.addDocument(title: 'First', description: '');
      await notifier.addDocument(title: 'Second', description: '');

      final docs = container.read(documentsProvider);
      expect(docs.length, 2);
      expect(docs.first.title, 'Second');
      expect(docs.last.title, 'First');
    });

    test('deleteDocument removes from state', () async {
      final notifier = container.read(documentsProvider.notifier);
      await notifier.addDocument(title: 'To Delete', description: '');
      final docId = container.read(documentsProvider).first.id;

      final success = await notifier.deleteDocument(docId);
      expect(success, true);
      expect(container.read(documentsProvider), isEmpty);
    });

    test('deleteDocument returns false on error', () async {
      final errorApi = _ErrorDocumentApi();
      final c = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(errorApi)],
      );

      final success = await c.read(documentsProvider.notifier).deleteDocument('nonexistent');
      expect(success, false);
      c.dispose();
    });

    test('addDocument returns false on error', () async {
      final errorApi = _ErrorDocumentApi();
      final c = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(errorApi)],
      );

      final success = await c.read(documentsProvider.notifier).addDocument(
        title: 'Test', description: '',
      );
      expect(success, false);
      c.dispose();
    });

    test('updateFromBootstrap replaces state', () {
      final docs = [
        const DocumentItem(
          id: '1', title: 'Doc 1', description: '',
          icon: Icons.abc, color: Colors.red,
          iconName: 'abc', colorHex: '#FF0000',
        ),
      ];
      container.read(documentsProvider.notifier).updateFromBootstrap(docs);
      expect(container.read(documentsProvider).length, 1);
    });
  });

  group('UserProfile', () {
    test('fromJson parses correctly', () {
      final json = {'name': 'Test', 'email': 'test@test.com'};
      final profile = UserProfile.fromJson(json);
      expect(profile.name, 'Test');
      expect(profile.email, 'test@test.com');
    });

    test('fromJson handles null fields', () {
      final profile = UserProfile.fromJson({});
      expect(profile.name, '');
      expect(profile.email, '');
    });

    test('toJson returns correct map', () {
      const profile = UserProfile(name: 'Test', email: 'a@b.com');
      final json = profile.toJson();
      expect(json['name'], 'Test');
      expect(json['email'], 'a@b.com');
    });
  });
}

class _ErrorDocumentApi extends FakeTravelApiService {
  _ErrorDocumentApi()
      : super(secureStorage: FakeSecureStorage());

  @override
  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    String icon = 'description',
    String color = '#176FF2',
  }) async {
    throw Exception('API error');
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    throw Exception('API error');
  }
}
