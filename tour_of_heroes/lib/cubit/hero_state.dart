import 'package:tour_of_heroes/models/hero_model.dart';

abstract class HeroState {}
class HeroInitial extends HeroState {}
class HeroLoading extends HeroState {}
class HeroLoaded extends HeroState {
  final List<HeroModel> heroes;
  HeroLoaded(this.heroes);
}
class HeroDetailLoaded extends HeroState {
  final HeroModel hero;
  HeroDetailLoaded(this.hero);
}
class HeroError extends HeroState {
  final String message;
  HeroError(this.message);
}