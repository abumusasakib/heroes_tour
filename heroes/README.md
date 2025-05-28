# heroes

## Running the Application Locally

Run `conduit serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run `conduit document client`.

## Database Migration

From your project directory, run the following command:

```dart
conduit db generate
```

This command will create a new migration file. A migration file is a Dart script that runs a series of SQL commands to alter a database's schema. It is created in a new directory in your project named migrations/.

Migrate:

```dart
conduit db upgrade --connect postgres://postgres:postgres@localhost:5432/heroes
```

## Rebuild your database

If you've modified the model and things still break, consider running:

```dart
dart run conduit db generate
dart run conduit db upgrade --connect postgres://username:password@localhost:5432/database_name
```

Make sure your database schema and Dart model are in sync.

## Running Application Tests

To run all tests for this application, run the following in this directory:

```dart
pub run test
```

The default configuration file used when testing is `config.src.yaml`. This file should be checked into version control. It also the template for configuration files used in deployment.

## Deploying an Application

See the documentation for [Deployment](https://conduit.io/docs/deploy/).
