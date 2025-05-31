import 'package:conduit_core/managed_auth.dart';
import 'package:heroes/heroes.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  late String password;
}

class _User extends ResourceOwnerTableDefinition {}
