# Introduction

Take your heroes on a tour to Dartland with Flutter and Conduit.

Dart is a modern, object-oriented language optimized for UI development, but it's also a great choice for backend development thanks to Conduit. Conduit is a robust and extensible server-side framework built with Dart that makes it easy to build RESTful APIs with strong typing, excellent performance, and integrated support for things like PostgreSQL, authentication, and request validation.

By using Dart for both your frontend (with Flutter) and backend (with Conduit), you can maintain consistency across your codebase, streamline onboarding, and speed up development with shared models and tooling.

Let's explore how this seamless full-stack Dart experience brings our heroes to life!

---

## Setup Instructions

### Backend (Conduit API)

### Key Features

- **CORS support**: Easily configured for cross-origin frontend requests.
- **PostgreSQL integration**: Powerful ORM and migration tools.
- **RESTful routes**: Auto-routed controllers with strong typing.
- **Swagger documentation**: Auto-generate client and route docs.
- **Authentication support**: Built-in options for secure endpoints.

### Getting Started

1. **Install Conduit CLI:**

   ```bash
   dart pub global activate conduit
   ```

2. **Run the server locally:**

   ```bash
   conduit serve
   ```

3. **SwaggerUI client generation (optional):**

   ```bash
   conduit document client
   ```

4. **Database migration commands:**

   - Generate migration files:

     ```bash
     conduit db generate
     ```

   - Apply migration to PostgreSQL:

     ```bash
     conduit db upgrade --connect postgres://postgres:postgres@localhost:5432/heroes
     ```

   - Rebuild if schema mismatch:

     ```bash
     dart run conduit db generate
     dart run conduit db upgrade --connect postgres://username:password@localhost:5432/database_name
     ```

5. **Run backend tests:**

   ```bash
   dart pub run test
   ```

   Tests use `config.src.yaml`.

6. **Deployment:**

   See the official [Conduit deployment guide](https://conduit.io/docs/deploy/).

---

## Frontend (Flutter App)

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Run the app:**

   ```bash
   flutter run
   ```

3. **Configure API base URL:**

   Update `lib/screens/api_settings_screen.dart` as needed.

---

## Project Structure

```text
├── heroes (Backend: Conduit API)
│   ├── lib
│   │   ├── controllers/       # REST API endpoints
│   │   ├── model/             # PostgreSQL-backed data models
│   │   ├── channel.dart       # App configuration and middleware (e.g., CORS)
│   │   └── heroes.dart        # Entry point
│   ├── bin/                   # Application bootstrap
│   ├── migrations/            # Database migration files
│   ├── config.yaml            # Default config
│   ├── config.src.yaml        # Config for tests
│   ├── test/                  # Unit and endpoint tests
│   └── pubspec.yaml

├── tour_of_heroes (Frontend: Flutter UI)
│   ├── lib
│   │   ├── cubit/             # State management
│   │   ├── models/            # Shared data models
│   │   ├── screens/           # UI pages
│   │   └── main.dart          # App entry point
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── windows/
│   ├── web/
│   └── pubspec.yaml
```
