import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_of_heroes/cubit/hero_state.dart';
import 'package:tour_of_heroes/models/hero_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeroCubit extends Cubit<HeroState> {
  final String baseUrl;
  List<HeroModel> _allHeroes = [];

  List<HeroModel> get allHeroes => _allHeroes;

  HeroCubit(this.baseUrl) : super(HeroInitial());

  Future<void> fetchHeroes() async {
    try {
      emit(HeroLoading());
      final response = await http.get(Uri.parse("$baseUrl/heroes"));
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );
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
      final response = await http.delete(Uri.parse("$baseUrl/heroes/$id"));
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
      final response = await http.get(Uri.parse("$baseUrl/heroes/$id"));
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
          .where(
              (hero) => hero.name.toLowerCase().contains(query.toLowerCase()))
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
