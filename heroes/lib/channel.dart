import 'package:conduit_core/managed_auth.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';
import 'package:heroes/controllers/cors_controller.dart';
import 'package:heroes/controllers/heroes_controller.dart';
import 'package:heroes/controllers/register_controller.dart';
import 'package:heroes/controllers/static_file_controller.dart';
import 'package:heroes/heroes.dart';
import 'package:heroes/model/user.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class HeroesChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  late ManagedContext context;

  late AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = HeroConfig(options!.configurationFilePath!);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Add CORS middleware globally
    router.route("/*").link(CORSController.new);

    // Serve client.html at root "/"
    router.route("/").link(StaticFileController.new);

    // Heroes API
    router
        .route('/heroes/[:id]')
        .link(() => Authorizer.bearer(authServer))
        ?.link(() => HeroesController(context));

    router.route('/auth/token').link(() => AuthController(authServer));

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));

    return router;
  }
}

class HeroConfig extends Configuration {
  HeroConfig(String path) : super.fromFile(File(path));

  late DatabaseConfiguration database;
}
