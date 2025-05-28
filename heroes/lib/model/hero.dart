import 'package:heroes/heroes.dart';

class Hero extends ManagedObject<_Hero> implements _Hero {}

class _Hero {
  @primaryKey
  int? id; // ✅ Nullable and NOT 'late'

  @Column(unique: true, nullable: false)
  late String name; // ✅ Using 'late' for non-nullable fields that will be set later
}

