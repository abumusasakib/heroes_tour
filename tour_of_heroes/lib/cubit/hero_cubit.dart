import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:tour_of_heroes/cubit/hero_state.dart';
import 'package:tour_of_heroes/models/hero_model.dart';
import 'package:tour_of_heroes/cubit/auth_cubit.dart';
import 'package:tour_of_heroes/storage/auth_storage.dart';

class HeroCubit extends Cubit<HeroState> {
  final String baseUrl;
  final AuthCubit authCubit;
  List<HeroModel> _allHeroes = [];

  List<HeroModel> get allHeroes => _allHeroes;

  HeroCubit({required this.baseUrl, required this.authCubit}) : super(HeroInitial());

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchHeroes() async {
    try {
      emit(HeroLoading());
      final response = await http.get(Uri.parse("$baseUrl/heroes"), headers: await _authHeaders());
      if (await authCubit.checkForUnauthorized(response)) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final heroes = jsonList.map((e) => HeroModel.fromJson(e)).toList();
        _allHeroes = heroes;
        emit(HeroLoaded(heroes));
      } else {
        emit(HeroError("Failed to load heroes"));
      }
    } catch (e) {
      emit(HeroError(e.toString()));
    }
  }

  Future<void> addHero(String name) async {
    try {
      emit(HeroLoading());
      final response = await http.post(
        Uri.parse("$baseUrl/heroes"),
        headers: await _authHeaders(),
        body: json.encode({'name': name}),
      );
      if (await authCubit.checkForUnauthorized(response)) return;

      if (response.statusCode == 200) {
        await fetchHeroes();
      } else {
        emit(HeroError("Failed to add hero"));
      }
    } catch (e) {
      emit(HeroError(e.toString()));
    }
  }

  Future<void> updateHero(int id, String newName) async {
    try {
      emit(HeroLoading());
      final response = await http.put(
        Uri.parse("$baseUrl/heroes/$id"),
        headers: await _authHeaders(),
        body: json.encode({'name': newName}),
      );
      if (await authCubit.checkForUnauthorized(response)) return;

      if (response.statusCode == 200) {
        await fetchHeroes();
      } else {
        emit(HeroError("Failed to update hero"));
      }
    } catch (e) {
      emit(HeroError(e.toString()));
    }
  }

  Future<void> deleteHero(int id) async {
    try {
      emit(HeroLoading());
      final response = await http.delete(
        Uri.parse("$baseUrl/heroes/$id"),
        headers: await _authHeaders(),
      );
      if (await authCubit.checkForUnauthorized(response)) return;

      if (response.statusCode == 200) {
        await fetchHeroes();
      } else {
        emit(HeroError("Failed to delete hero"));
      }
    } catch (e) {
      emit(HeroError(e.toString()));
    }
  }

  Future<void> getHeroById(int id) async {
    try {
      emit(HeroLoading());
      final response = await http.get(
        Uri.parse("$baseUrl/heroes/$id"),
        headers: await _authHeaders(),
      );
      if (await authCubit.checkForUnauthorized(response)) return;

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final hero = HeroModel.fromJson(jsonData);
        emit(HeroDetailLoaded(hero));
      } else {
        emit(HeroError("Failed to load hero"));
      }
    } catch (e) {
      emit(HeroError(e.toString()));
    }
  }

  void searchHero(String query) {
    if (state is HeroLoaded || state is HeroDetailLoaded) {
      final filtered = _allHeroes
          .where((hero) => hero.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(HeroLoaded(filtered));
    }
  }

  void clearHeroDetail() {
    if (_allHeroes.isNotEmpty) {
      emit(HeroLoaded(_allHeroes));
    } else {
      fetchHeroes();
    }
  }
}
