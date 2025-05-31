import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:conduit_core/conduit_core.dart';
import 'package:heroes/model/user.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    // Check for required parameters before we spend time hashing
    if (user.username == null) {
      return Response.badRequest(
          body: {"error": "username and password required."});
    }

    user
      ..salt = generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt!);

    return Response.ok(await Query(context, values: user).insert());
  }
}

String generateRandomSalt() {
  // Generate a random salt for password hashing
  final random = Random.secure();
  final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64.encode(saltBytes);
}
