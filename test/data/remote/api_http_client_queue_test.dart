import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/remote/api_http_client.dart';
import 'package:online_travel_agent/data/remote/auth_api_service.dart';
import 'package:online_travel_agent/core/utils/api_exception.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late String unavailableBaseUrl;

  setUp(() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unavailableBaseUrl = 'http://${server.address.address}:${server.port}';
    await server.close(force: true);
  });

  test('auth credentials are never written to the offline queue', () async {
    final queuedBodies = <Map<String, dynamic>?>[];
    final client = ApiHttpClient(
      baseUrl: unavailableBaseUrl,
      secureStorage: FakeSecureStorage(),
      queueRequestWriter: (method, path, body) async => queuedBodies.add(body),
    );

    await expectLater(
      AuthApiService(
        client,
      ).login(email: 'user@example.com', password: 'secret'),
      throwsA(isA<NetworkException>()),
    );
    expect(queuedBodies, isEmpty);
  });

  test('mutation queueing is opt-in rather than the default', () async {
    final queuedPaths = <String>[];
    final client = ApiHttpClient(
      baseUrl: unavailableBaseUrl,
      secureStorage: FakeSecureStorage(),
      queueRequestWriter: (method, path, body) async => queuedPaths.add(path),
    );

    await expectLater(
      client.postJson('/api/documents', {'title': 'Passport'}),
      throwsA(isA<NetworkException>()),
    );
    expect(queuedPaths, isEmpty);
  });

  test('logout clears the local session before revoking it remotely', () async {
    final storage = FakeSecureStorage();
    await storage.write(key: 'auth_token', value: 'access-token');
    await storage.write(key: 'auth_refresh_token', value: 'refresh-token');

    late ApiHttpClient client;
    final observedLocalClear = Completer<bool>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      observedLocalClear.complete(
        client.token == null &&
            client.refreshToken == null &&
            storage.data['auth_token'] == null &&
            storage.data['auth_refresh_token'] == null,
      );
      request.response
        ..statusCode = 200
        ..write('{}');
      await request.response.close();
    });

    client = ApiHttpClient(
      baseUrl: 'http://${server.address.address}:${server.port}',
      secureStorage: storage,
    );
    await client.loadTokenFuture;

    await client.logout();

    expect(await observedLocalClear.future, true);
    await server.close(force: true);
  });
}
