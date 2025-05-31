import 'dart:convert';

import 'package:http/http.dart' as http;


Future<void> createTestUser() async {
  await http.post(
    Uri.parse("http://localhost:8888/register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": "bob",
      "password": "password",
    }),
  );
}
