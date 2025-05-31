import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'utils/test_user.dart';

void main() {
  const clientID = "com.heroes.tutorial";
  const body = "username=bob&password=password&grant_type=password";
  final String clientCredentials =
      const Base64Encoder().convert("$clientID:".codeUnits);

  setUp(() async {
    await createTestUser();
  });

  test('Token endpoint returns valid access token', () async {
    final response = await http.post(
      Uri.parse("http://localhost:8888/auth/token"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic $clientCredentials",
      },
      body: body,
    );

    // Parse response body
    final responseData = jsonDecode(response.body);

    // Always print the response body for debugging
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      expect(responseData, contains('access_token'));
      expect(responseData, contains('token_type'));
      expect(responseData['token_type'], equals('bearer'));
      expect(responseData, contains('expires_in'));
    } else {
      // Test should still fail gracefully with an informative message
      fail("Token request failed with: ${response.body}");
    }
  });
}
