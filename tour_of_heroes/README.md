# Tour of Heroes

## Key Features

* **Dashboard View**: Highlights top heroes visually in a grid layout.
* **Hero Search**: Real-time search box to filter and select heroes.
* **Hero Detail View**: View and update hero details like ID and name.

## REST Integration

Connects to the Dart Conduit API (`http://localhost:8888/heroes`) for:

* `GET /heroes`: Fetch all heroes
* `GET /heroes/:id`: Fetch hero detail
* `PUT /heroes/:id`: Update hero
* `POST /heroes`: Add a new hero
* `DELETE /heroes/:id`: Delete hero

> CORS is enabled in the Conduit backend (`channel.dart`) for Flutter web compatibility.

## Example Usage

```dart
final response = await http.get(Uri.parse('http://localhost:8888/heroes'));
final List<dynamic> heroes = jsonDecode(response.body);
```

## Notes

* Ensure the backend server and frontend are hosted on compatible ports or configure proxy/CORS.
