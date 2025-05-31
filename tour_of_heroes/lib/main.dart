import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tour_of_heroes/cubit/auth_cubit.dart';
import 'package:tour_of_heroes/cubit/auth_state.dart';
import 'package:tour_of_heroes/cubit/hero_cubit.dart';
import 'package:tour_of_heroes/screens/auth_screen.dart';
import 'package:tour_of_heroes/screens/hero_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiBaseUrl = await _loadApiBaseUrl(); // load on startup
  runApp(MyApp(initialUrl: apiBaseUrl));
}

Future<String> _loadApiBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('api_base_url') ?? "http://localhost:8888";
}

class MyApp extends StatelessWidget {
  final ValueNotifier<String> apiBaseUrl;

  MyApp({super.key, required String initialUrl})
      : apiBaseUrl = ValueNotifier(initialUrl);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: apiBaseUrl,
      builder: (context, baseUrl, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthCubit(baseUrl: baseUrl)..checkAuthStatus(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tour of Heroes',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return BlocProvider(
                    create: (_) => HeroCubit(
                      baseUrl: baseUrl,
                      authCubit: context.read<AuthCubit>(),
                    )..fetchHeroes(),
                    child: HeroListScreen(apiBaseUrl: apiBaseUrl),
                  );
                } else if (state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return AuthScreen(apiBaseUrl: apiBaseUrl);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
