# Tour of Heroes

## Key Features

- **Dashboard View**: Highlights top heroes visually in a grid layout.
- **Hero Search**: Real-time search box to filter and select heroes.
- **Hero Detail View**: View and update hero details like ID and name.

---

## Authentication

This frontend app integrates with the Conduit OAuth 2.0 authentication system.

### Register & Login Flow

Users can:

- Register via `POST /register`
- Authenticate using `POST /auth/token` with the OAuth 2.0 password grant
- All authenticated requests include the bearer token in the `Authorization` header

The access token is persisted using `shared_preferences` and automatically applied to all protected API endpoints.

### Example Auth Headers

```http
Authorization: Bearer <access_token>
```

> ⚠️ If the token is invalid or expired, the app automatically logs out and redirects the user to the login screen.

---

## REST Integration

Connects to the Dart Conduit API (`http://localhost:8888/heroes`) for:

- `GET /heroes`: Fetch all heroes
- `GET /heroes/:id`: Fetch hero detail
- `PUT /heroes/:id`: Update hero
- `POST /heroes`: Add a new hero
- `DELETE /heroes/:id`: Delete hero

> CORS is enabled in the Conduit backend (`channel.dart`) for Flutter web compatibility.

---

## Example Usage

```dart
final response = await http.get(
  Uri.parse('http://localhost:8888/heroes'),
  headers: {
    'Authorization': 'Bearer your_access_token',
  },
);
final List<dynamic> heroes = jsonDecode(response.body);
```

---

## Notes

- Ensure the backend server and frontend are hosted on compatible ports or configure proxy/CORS.
- The API Base URL is editable from the settings screen and persisted across app restarts.
