# What is Hexa?

Hexa can be considered a light way Framework.

It is optimized for the appliance of best practices (BDD, TDD, Design, easier to refactor).
Well, actually all depends on you but at least it doesn't limit you
(you know, usually your logic depends on the framework when should be the opposite).
I encourage you to see this [keynote](https://www.youtube.com/watch?v=WpkDN78P884) which was the starting motivation of `Hexa`

**Embrace separation of concerns**  
It primary design mission is to keep side-effects, business-logic, and presentation-logic separated from each other.

**It is Use-Case centered**  
A use-case is defined as a set of actions reflecting user-intentions coming from the browser to the system.

In order to allow features scalability without making your code a mess.
This "framework" divides the whole application into smaller applications.
Each of these smaller applications represents just one use case.  
![folder structure]()
These small applications follow an [hexagonal architecture](<https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)>)  
So each use-case has its own `API - BusinessLogic - DBAccess` within a small scope that you can easily navigate.  

The fact that is use-case centered suggest that you can take advantages of documenting your [DSS](https://en.wikipedia.org/wiki/System_sequence_diagram)
I know, maitaining that is a pain in the ass, but working on a big project with many other devs is the high level picture that you would wish to have.  

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
