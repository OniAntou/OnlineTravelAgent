import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/remote/api_http_client.dart';
import 'package:online_travel_agent/data/remote/document_api_service.dart';
import 'package:online_travel_agent/data/remote/review_api_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ApiHttpClient refresh handling', () {
    late HttpServer server;
    late ApiHttpClient client;
    var refreshCalls = 0;
    var authErrors = 0;

    setUp(() async {
      refreshCalls = 0;
      authErrors = 0;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        if (request.uri.path == '/api/auth/refresh') {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await _respondJson(request, 200, {
            'token': 'fresh-token',
            'refreshToken': 'next-refresh-token',
          });
          return;
        }

        if (request.headers.value(HttpHeaders.authorizationHeader) !=
            'Bearer fresh-token') {
          await _respondJson(request, 401, {'message': 'expired token'});
          return;
        }

        await _respondJson(request, 200, {'ok': true});
      });

      client = ApiHttpClient(
        baseUrl: 'http://${server.address.address}:${server.port}',
        secureStorage: FakeSecureStorage(),
      );
      await client.loadTokenFuture;
      client.token = 'expired-token';
      client.refreshToken = 'refresh-token';
      client.onAuthError = () => authErrors++;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test(
      'shares one refresh when two authenticated requests expire together',
      () async {
        final responses = await Future.wait([
          client.getJson('/api/protected'),
          client.getJson('/api/protected'),
        ]);

        expect(responses, everyElement({'ok': true}));
        expect(refreshCalls, 1);
        expect(authErrors, 0);
      },
    );

    test(
      'retries document and review deletion through the shared client',
      () async {
        final documents = DocumentApiService(client);
        final reviews = ReviewApiService(client);

        final deleted = await Future.wait([
          documents.deleteDocument('document-1'),
          reviews.deleteReview('review-1'),
        ]);

        expect(deleted, [true, true]);
        expect(refreshCalls, 1);
        expect(authErrors, 0);
      },
    );
  });
}

Future<void> _respondJson(
  HttpRequest request,
  int statusCode,
  Map<String, dynamic> body,
) async {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body));
  await request.response.close();
}
