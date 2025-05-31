# heroes (Backend README)

## Running the Application Locally

Run `conduit serve` from this directory to run the application.

To generate a SwaggerUI client, run:

```bash
conduit document client
```

---

## Setting Up a Database

### Installing PostgreSQL

For development, you'll need to install a PostgreSQL server on your local machine.

- **macOS**: Use [Postgres.app](https://postgresapp.com/), a native macOS application that manages PostgreSQL servers.
- **Other Platforms**: Set up PostgreSQL using the method appropriate for your operating system.

> ⚠️ **PostgreSQL 9.6 or Greater is Required**
> Conduit requires PostgreSQL version 9.6 or newer.

---

### Create Database and User in DBeaver (or psql)

Connect to your PostgreSQL server as the `postgres` superuser and run the following SQL commands:

```sql
CREATE DATABASE heroes;
CREATE USER heroes_user WITH
    SUPERUSER
    CREATEDB
    CREATEROLE
    INHERIT
    LOGIN
    REPLICATION
    BYPASSRLS
    CONNECTION LIMIT -1;
ALTER USER heroes_user WITH password 'password';
GRANT ALL ON DATABASE heroes TO heroes_user;
```

---

### Generate and Apply a Migration

Create the migration file that sets up your schema:

```bash
conduit db generate
```

Apply the migration to your local `heroes` database:

```bash
conduit db upgrade --connect postgres://heroes_user:password@localhost:5432/heroes
```

Start the application:

```bash
conduit serve
```

---

## Rebuild Your Database (if needed)

If you've modified the model and things still break, ensure the schema is in sync:

```bash
dart run conduit db generate
dart run conduit db upgrade --connect postgres://heroes_user:password@localhost:5432/heroes
```

---

## Running Application Tests

Run all tests:

```bash
dart pub run test
```

The test configuration uses `config.src.yaml`, which also serves as a deployment config template.

---

### Setting up Your Test Database (`dart_test`)

Conduit uses a test database `dart_test` for automated testing, configured in `config.src.yaml`.

To create the test database and user:

```sql
CREATE DATABASE dart_test;
CREATE USER dart WITH CREATEDB;
ALTER USER dart WITH PASSWORD 'dart';
GRANT ALL ON DATABASE dart_test TO dart;
```

> 💡 **dart_test Database**
> You only have to create this test database once per machine. Conduit uses temporary tables during testing, so no data persists. You can even run multiple applications' tests simultaneously using the same `dart_test` DB.

---

## Setting Up OAuth 2.0: Authenticating Users

Conduit supports OAuth 2.0 authentication using the `AuthController`.

### Registering a Client

In OAuth 2.0, a **client** is any application that interacts with your server on behalf of a user (e.g., mobile, web). Each client must be registered in the system.

Run the following command to register a new client:

```bash
conduit auth add-client --id com.heroes.tutorial --connect postgres://heroes_user:password@localhost:5432/heroes
```

> ℹ️ **Note:** Clients may also have a secret, redirect URI, or scopes. If a client has a secret, it can issue refresh tokens.

---

### Authenticating with Username and Password

Once a client is registered, use the following request to issue an access token:

**Curl Example:**

```bash
curl -X POST http://localhost:8888/auth/token \
  -H 'Authorization: Basic Y29tLmhlcm9lcy50dXRvcmlhbDo=' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'username=bob&password=password&grant_type=password'
```

The request must:

- Use `POST` to `/auth/token`
- Set `Content-Type: application/x-www-form-urlencoded`
- Include these keys in the body:

  - `username`: the user's username
  - `password`: the user's password
  - `grant_type`: must be `password`

- Use a **Basic Authorization header** with the base64 encoded `clientID:` string

Example successful response:

```json
{
  "access_token": "687PWKFHRTQ9MveQ2dKvP95D4cWie1gh",
  "token_type": "bearer",
  "expires_in": 86399
}
```

---

You can now use the access token to make authorized API requests by setting the `Authorization` header:

```http
Authorization: Bearer 687PWKFHRTQ9MveQ2dKvP95D4cWie1gh
```
