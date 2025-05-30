import 'package:heroes/model/hero.dart';
import 'harness/app.dart';

void main() {
  final harness = Harness()..install();

  test("GET /heroes returns 200 OK", () async {
    final query = Query<Hero>(harness.application!.channel.context)
      ..values.name = "Bob";
    await query.insert();

    final response = await harness.agent?.get("/heroes");
    expectResponse(response, 200,
        body: allOf([
          hasLength(greaterThan(0)),
          everyElement({
            "id": greaterThan(0),
            "name": isString,
          })
        ]));
  });

  test("GET /heroes/:id returns 200 OK", () async {
    final query = Query<Hero>(harness.application!.channel.context)
      ..values.name = "Alice";

    final hero = await query.insert();

    final response = await harness.agent?.get("/heroes/${hero.id}");
    expectResponse(response, 200, body: {
      "id": hero.id,
      "name": "Alice",
    });
  });

  test("GET /heroes/:id returns 404 Not Found for non-existent hero", () async {
    final response = await harness.agent?.get("/heroes/9999");
    expectResponse(response, 404);
  });

  test("POST /heroes returns 200 OK on first post, 409 on duplicate", () async {
    final response =
        await harness.agent?.post("/heroes", body: {"name": "Fred"});
    expectResponse(response, 200);

    final duplicateResponse =
        await harness.agent?.post("/heroes", body: {"name": "Fred"});
    expectResponse(duplicateResponse, 409);
  });

  test("PUT /heroes/:id updates hero name and returns 200 OK", () async {
    final insert = Query<Hero>(harness.application!.channel.context)
      ..values.name = "HeroToUpdate";
    final hero = await insert.insert();

    final response = await harness.agent
        ?.put("/heroes/${hero.id}", body: {"name": "UpdatedHero"});

    expectResponse(response, 200, body: {
      "id": hero.id,
      "name": "UpdatedHero",
    });
  });

  test("PUT /heroes/:id returns 404 Not Found for non-existent hero", () async {
    final response =
        await harness.agent?.put("/heroes/9999", body: {"name": "Nobody"});
    expectResponse(response, 404);
  });

  test("DELETE /heroes/:id deletes hero and returns 200 OK", () async {
    final insert = Query<Hero>(harness.application!.channel.context)
      ..values.name = "HeroToDelete";
    final hero = await insert.insert();

    final response = await harness.agent?.delete("/heroes/${hero.id}");
    expectResponse(response, 200, body: {"deleted": 1});
  });

  test("DELETE /heroes/:id returns 404 Not Found for non-existent hero",
      () async {
    final response = await harness.agent?.delete("/heroes/9999");
    expectResponse(response, 404);
  });
}
