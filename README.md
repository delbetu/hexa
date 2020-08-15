## Starting up the application

Starts a web server connected to a database

```shell
$> docker-compose up --build
```

## IRB console

Loads gems, files under /lib

```shell
$>  ./bin/console
```

## Database Console

```shell
$> ./bin/db/console
```

## Sequel Console

```shell
$> ./bin/sequel_console
```

## Create/Destroy Database

```shell
$> ./bin/db/create
$> ./bin/db/drop
```

## Environment Variable

RACK_ENV sets the current environment
.env variables are loaded into ENV
Check .env.template

## Migrations

### Running Migrations

```shell
$> ./bin/db/migrate
```

### Dumping Schema

```shell
$> ./bin/db/dump
$> cat db/schema.rb
```

### Running tests
Tests recreate a sqlite in memory db when running them.  

```shell
$> bundle exec rspec
```

### Load Seed Data

```shell
$> ./bin/db/seed
```

### List Tables

```shell
$> ./bin/db/tables
```

## Deploying to Heroku

Requires environment variable APP_ROOT='/app' in heorku.

```shell
$> git push heroku master
```
