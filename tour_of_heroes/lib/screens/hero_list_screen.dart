// UI
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_of_heroes/cubit/hero_cubit.dart';
import 'package:tour_of_heroes/cubit/hero_state.dart';
import 'package:tour_of_heroes/models/hero_model.dart';
import 'package:tour_of_heroes/screens/api_settings_screen.dart';

class HeroListScreen extends StatelessWidget {
  final ValueNotifier<String> apiBaseUrl;

  HeroListScreen({super.key, required this.apiBaseUrl});

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text("Tour of Heroes", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              final newUrl = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ApiSettingsScreen(currentUrl: apiBaseUrl.value),
                ),
              );
              if (newUrl != null && newUrl != apiBaseUrl.value) {
                apiBaseUrl.value = newUrl;
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top Heroes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BlocBuilder<HeroCubit, HeroState>(
              builder: (context, state) {
                if (state is HeroLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HeroError) {
                  return Center(child: Text("Error: ${state.message}"));
                } else {
                  List<HeroModel> heroes = [];
                  HeroModel? selectedHero;

                  if (state is HeroLoaded) {
                    heroes = state.heroes;
                  } else if (state is HeroDetailLoaded) {
                    selectedHero = state.hero;
                    final currentState = context.read<HeroCubit>().state;
                    if (currentState is HeroLoaded) {
                      heroes = currentState.heroes;
                    }
                  }

                  final topHeroes =
                      heroes.length >= 4 ? heroes.sublist(0, 4) : heroes;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: topHeroes.map((hero) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<HeroCubit>()
                                      .getHeroById(hero.id),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF527285),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        hero.name,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Text("Hero Search",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search heroes...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (query) {
                              context.read<HeroCubit>().searchHero(query);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (selectedHero != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${selectedHero.name} details!",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text("ID: ${selectedHero.id}"),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    controller: TextEditingController(
                                        text: selectedHero.name),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => context
                                            .read<HeroCubit>()
                                            .clearHeroDetail(),
                                        child: const Text("Back"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: heroes
                                .where((hero) => hero.name
                                    .toLowerCase()
                                    .contains(
                                        _searchController.text.toLowerCase()))
                                .map((hero) => Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                      child: GestureDetector(
                                        onTap: () => context
                                            .read<HeroCubit>()
                                            .getHeroById(hero.id),
                                        child: Text(hero.name),
                                      ),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
