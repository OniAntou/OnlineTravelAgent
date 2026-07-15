import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/remote/api_http_client.dart';

void main() {
  group('ApiHttpClient base URL resolution', () {
    test('rejects an insecure API URL in release mode', () {
      expect(
        () => ApiHttpClient.resolveBaseUrl(
          apiBaseUrl: 'http://api.example.com',
          releaseMode: true,
          isAndroid: false,
        ),
        throwsStateError,
      );
    });

    test('accepts an HTTPS API URL in release mode', () {
      expect(
        ApiHttpClient.resolveBaseUrl(
          apiBaseUrl: 'https://api.example.com',
          releaseMode: true,
          isAndroid: false,
        ),
        'https://api.example.com',
      );
    });
  });
}
