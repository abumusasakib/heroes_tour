import 'package:heroes/heroes.dart';

class StaticFileController extends Controller {
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    final file = File('client.html');
    if (file.existsSync()) {
      final content = await file.readAsString();
      return Response.ok(content)
        ..contentType = ContentType.html;
    } else {
      return Response.notFound(body: {'error': 'File not found'});
    }
  }
}
