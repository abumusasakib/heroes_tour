# heroes (Backend README)

## Running the Application Locally

Run `conduit serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

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

## Deploying the Application

Refer to the official [Conduit Deployment Guide](https://conduit.io/docs/deploy/).
