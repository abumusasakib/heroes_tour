// UI
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tour_of_heroes/cubit/auth_cubit.dart';
import 'package:tour_of_heroes/cubit/hero_cubit.dart';
import 'package:tour_of_heroes/cubit/hero_state.dart';
import 'package:tour_of_heroes/models/hero_model.dart';
import 'package:tour_of_heroes/screens/api_settings_screen.dart';
import 'package:tour_of_heroes/storage/auth_storage.dart';

class HeroListScreen extends StatefulWidget {
  final ValueNotifier<String> apiBaseUrl;

  const HeroListScreen({super.key, required this.apiBaseUrl});

  @override
  State<HeroListScreen> createState() => _HeroListScreenState();
}

class _HeroListScreenState extends State<HeroListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newHeroController = TextEditingController();
  final TextEditingController _editHeroController = TextEditingController();

  List<HeroModel> _allHeroes = [];

  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthStorage.getUsername();
    setState(() {
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _username != null ? "Welcome, $_username" : "Tour of Heroes",
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              final newUrl = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ApiSettingsScreen(currentUrl: widget.apiBaseUrl.value),
                ),
              );
              if (newUrl != null && newUrl != widget.apiBaseUrl.value) {
                widget.apiBaseUrl.value = newUrl;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHeroDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<HeroCubit, HeroState>(
              builder: (context, state) {
                if (state is HeroLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HeroError) {
                  return Center(child: Text("Error: ${state.message}"));
                } else {
                  HeroModel? selectedHero;

                  if (state is HeroLoaded) {
                    _allHeroes = state.heroes; // Cache full list once loaded
                  } else if (state is HeroDetailLoaded) {
                    selectedHero = state.hero;
                    final currentState = context.read<HeroCubit>().state;
                    if (currentState is HeroLoaded) {
                      _allHeroes = currentState.heroes;
                    }
                  }

                  final topHeroes =
                      context.read<HeroCubit>().allHeroes.take(4).toList();

                  final filteredHeroes = _searchController.text.isEmpty
                      ? _allHeroes
                      : _allHeroes
                          .where((hero) => hero.name
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .toList();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (topHeroes.isNotEmpty) ...[
                            const Text("Top Heroes",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
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
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (selectedHero == null) ...[
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
                          ],
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
                                    controller: _editHeroController
                                      ..text = selectedHero.name,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
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
                                        onPressed: () => context
                                            .read<HeroCubit>()
                                            .updateHero(selectedHero!.id,
                                                _editHeroController.text),
                                        child: const Text("Save"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () => context
                                            .read<HeroCubit>()
                                            .deleteHero(selectedHero!.id),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          if (selectedHero == null)
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: filteredHeroes
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

  void _showAddHeroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Hero"),
        content: TextField(
          controller: _newHeroController,
          decoration: const InputDecoration(hintText: "Enter hero name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HeroCubit>().addHero(_newHeroController.text);
              _newHeroController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
