# heroes (Backend README)

## Running the Application Locally

Run `conduit serve` from this directory to run the application. For running within an IDE, run `bin/main.dart`. By default, a configuration file named `config.yaml` will be used.

To generate a SwaggerUI client, run:

```bash
conduit document client
```

## Database Migration

Generate a new migration file:

```bash
conduit db generate
```

Apply the migration:

```bash
conduit db upgrade --connect postgres://postgres:postgres@localhost:5432/heroes
```

## Rebuild Your Database

If you've modified the model and things still break, make sure the schema is in sync:

```bash
dart run conduit db generate
dart run conduit db upgrade --connect postgres://username:password@localhost:5432/database_name
```

## Running Application Tests

Run all tests:

```bash
dart pub run test
```

The test configuration uses `config.src.yaml`, which also serves as a deployment config template.

## Deploying the Application

Refer to the official [Conduit Deployment Guide](https://conduit.io/docs/deploy/).
