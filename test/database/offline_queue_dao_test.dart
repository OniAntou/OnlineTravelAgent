import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:online_travel_agent/database/app_database.dart';
import 'dart:convert';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('should insert and fetch items from offline queue', () async {
    final dao = database.offlineQueueDao;

    // Insert item
    await dao.insertItem(
      OfflineQueueTableCompanion.insert(
        endpoint: '/api/v1/test',
        method: 'POST',
        bodyJson: const Value('{"key": "value"}'),
      ),
    );

    // Get all items
    final queue = await dao.getAll();
    expect(queue.length, 1);
    expect(queue.first.endpoint, '/api/v1/test');
    expect(queue.first.method, 'POST');
    expect(jsonDecode(queue.first.bodyJson!)['key'], 'value');
  });

  test('should clear the queue properly', () async {
    final dao = database.offlineQueueDao;

    await dao.insertItem(
      OfflineQueueTableCompanion.insert(
        endpoint: '/api/v1/test',
        method: 'POST',
      ),
    );

    await dao.clearQueue();
    final queue = await dao.getAll();
    expect(queue.isEmpty, true);
  });
}
