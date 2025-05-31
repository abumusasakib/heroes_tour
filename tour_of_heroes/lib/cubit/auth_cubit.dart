import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:tour_of_heroes/cubit/auth_state.dart';
import 'package:tour_of_heroes/storage/auth_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  final String baseUrl;

  AuthCubit({required this.baseUrl}) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      const clientID = "com.heroes.tutorial";
      final body = "username=$username&password=$password&grant_type=password";
      final clientCredentials =
          const Base64Encoder().convert("$clientID:".codeUnits);

      final response = await http.post(
        Uri.parse("$baseUrl/auth/token"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Basic $clientCredentials",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          await AuthStorage.saveToken(accessToken);
          await AuthStorage.saveUsername(username);

          emit(AuthAuthenticated(accessToken));
        } else {
          emit(AuthError("Invalid token response"));
        }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final data = json.decode(response.body);
        final error = data['error'] ?? '';

        if (error == 'invalid_grant') {
          emit(AuthError("Invalid username or password"));
        } else {
          emit(AuthError(
              data['error_description'] ?? error ?? "Authentication failed"));
        }
      } else {
        emit(AuthError("Unexpected server error (${response.statusCode})"));
      }
    } catch (e) {
      emit(AuthError("Login failed: ${e.toString()}"));
    }
  }

  Future<void> register(String username, String password) async {
    emit(AuthLoading());

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        await login(username, password);
      } else if (response.statusCode == 409) {
        final data = json.decode(response.body);
        emit(AuthError("Username already exists: ${data['detail'] ?? ''}"));
      } else {
        final data = json.decode(response.body);
        emit(AuthError(
            data['error'] ?? "Registration failed (${response.statusCode})"));
      }
    } catch (e) {
      emit(AuthError("Registration failed: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuthStatus() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      emit(AuthAuthenticated(token));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> handleUnauthorized() async {
    await logout();
  }

  Future<bool> checkForUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      await handleUnauthorized();
      return true;
    }
    return false;
  }
}
