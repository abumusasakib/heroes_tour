import 'package:heroes/heroes.dart';
import 'package:heroes/model/hero.dart';

class HeroesController extends ResourceController {
  HeroesController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllHeroes({@Bind.query('name') String? name}) async {
    final heroQuery = Query<Hero>(context);
    if (name != null) {
      heroQuery.where((h) => h.name).contains(name, caseSensitive: false);
    }
    final heroes = await heroQuery.fetch();

    return Response.ok(heroes);
  }

  @Operation.get('id')
  Future<Response> getHeroByID(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)..where((h) => h.id).equalTo(id);

    final hero = await heroQuery.fetchOne();

    if (hero == null) {
      return Response.notFound();
    }
    return Response.ok(hero);
  }

  @Operation.post()
  Future<Response> createHero(@Bind.body(ignore: ["id"]) Hero inputHero) async {
    final query = Query<Hero>(context)..values = inputHero;

    try {
      final insertedHero = await query.insert();
      return Response.ok(insertedHero);
    } catch (e) {
      if (e.toString().contains('23505')) {
        // Unique violation
        return Response.conflict(body: {'error': 'Hero name must be unique.'});
      }
      rethrow;
    }
  }

  @Operation.put('id')
  Future<Response> updateHero(@Bind.path('id') int id) async {
    final Map<String, dynamic>? body = await request?.body.decode();
    final query = Query<Hero>(context)
      ..where((h) => h.id).equalTo(id)
      ..values.name = body?['name'] as String;

    final updatedHero = await query.updateOne();

    if (updatedHero == null) {
      return Response.notFound();
    }
    return Response.ok(updatedHero);
  }

  @Operation.delete('id')
  Future<Response> deleteHero(@Bind.path('id') int id) async {
    final query = Query<Hero>(context)..where((h) => h.id).equalTo(id);

    final deletedCount = await query.delete();

    if (deletedCount == 0) {
      return Response.notFound();
    }
    return Response.ok({'deleted': deletedCount});
  }
}
