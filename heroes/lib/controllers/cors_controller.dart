import 'dart:async';

import 'package:conduit_core/conduit_core.dart';

class CORSController extends Controller {
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    request.addResponseModifier((response) {
      response.headers.addAll({
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      });
    });

    // Preflight request
    if (request.method == "OPTIONS") {
      return Response.ok(null);
    }

    return request;
  }
}
