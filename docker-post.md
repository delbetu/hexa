---
title: Dockerizing your app
published: false
description:
tags:
//cover_image: https://direct_url_to_image.jpg
---

## Intro

If you're a developer and you've heard that docker is pretty cool but you don't want to spend a lot of time reading its documentation in order to learn how to use it.  
Instead you want a hands-on guide to help you with the process of dockerizing an existing application, then keep reading because that is exactly what we will do on this post.

Some of the advantages of having a dockerized environment are:

- Avoid installing/updating different versions of services on your machine.
- New devs will have the application up and running in seconds rather than hours, following a straightforward process (windows, mac or linux).
- All devs will use the same versions so won't be conflict with generated files such us database dumps.

## Hands-on

Lets suppose that you have an application within a directory called `demo_app`  
This demo_app depends on several services running.  
During this post we will introduce each of these services one by one ensuring that they work Ok.

Lets suppose that `demo_app` uses ES6, Ruby and depends on:

1. postgres
2. redis
3. sidekiq
4. rack

Before continuing, some concepts that we need to keep in mind.

**Containers**(virtual-machines) need to load **images** (like .iso files)  
**images** can be downloaded from [docker-hub](https://hub.docker.com/search?q=&type=image) or created from a Dockerfile.  
A **Service** is a **container**(virtual machine) running a command.  
Services are configured in `docker-compose.yml`

## Postgres

File: docker-compose.yml

```yaml
version: "3"
services:
  postgres:
    image: "postgres:12.2"
    container_name: "demo_app_postgres"
    ports:
      - 54321:5432
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust
    volumes:
      - db_volume:/var/lib/postgresql/data

volumes:
  db_volume:
```

After running this command:  
`$> docker-compose up --build`  
docker compose will:

1. download the image "postgres:12.2" from docker-hub
2. run a container (virtual-machine) named "demo_app_postgres" based on the previous image.
3. It will open and map a port of the virtual machine, so you can access from your computer. (running telnet localhost 54321 will hit port 5432 of the virtual machine)
4. Set environment variable so there is no need to pass a password for the connection
5. Will create a fake HDD in your directory `/var/lib/docker/volumes/db_volume` and will mount it into --> container `/var/lib/postgresql/data`

You should be able to connect from your machine now.  
If you already have a postgres service running on localhost, ensure to stop it  
 `postgres://<username>:<pss>@<host>:<port>/<dbname>`

```shell
$> psql postgres://postgres:@localhost:54321/postgres
psql (12.3, server 12.2 (Debian 12.2-2.pgdg100+1))
Type "help" for help.

postgres=# exit
```

## Redis

File: `docker-compose.yml`

```yaml
services:
  redis:
    image: "redis"
    container_name: "demo_app_redis"
    ports:
      - 63791:6379
    command: redis-server
    volumes:
      - redis_volume:/data

volumes:
  redis_volume:
```

Nothing new to explain here.
To test this works you can:

```shell
redis-cli -h localhost -p 63791
localhost:63791>
```

## Sidekiq

Before writing the docker-compose entry, lets ensure that we can start sidekiq in our machine.

1. run configured services postgres and redis `docker-compose up`
2. run sidekiq `REDIS_URL=redis://localhost:63791/0 sidekiq -r worker.rb`

The key question here is: How do you prepare this container to support this command ?  
Our container will need:

- ensure redis service starts before this one => add a service dependency
- Ruby installed => start from ruby image
- REDIS_URL environment var => define this env var
- have sidekiq command installed => run 'gem install sidekiq' on container
- have access to worker.rb => we can mount your project dir into '/demo_app' of container

File: `docker-compose.yml`

```yaml
sidekiq:
  container_name: "demo_app_sidekiq"
  depends_on:
    - redis
  image: "ruby:2.7"
  command: bash -C "gem install sidekiq && sidekiq -r ./demo_app/worker.rb"
  environment:
    - REDIS_URL=redis://redis:6379/0
  volumes:
    - .:/demo_app
```

(Note that the redis host is not localhost instead is accesseing using its service name and default port)

## Rack

Lets try this command in your machine:  
`DATABASE_URL=... REDIS_URL=... bundle exec rackup -I lib -p 3000`  
This starts an application server listening on port 3000  
key question: How do we create a container to support this command?

Our container will need:

- All other services need to be running => add a service dependency
- All the code needs to be available here => mount current dir into the container
- Ruby => start from ruby image
- gems within gemfile => install gems within 'vendor/bundle' config bundle to look for gems there.
- other linux liraries such as imagemagik => apt-get install within Dockerfile
- REDIS_URL DATABASE_URL and other environment vars => define this env var in the new image

Since the provisioning comes a little more complex here so we can create a new docker image on top of the ruby image.  
For that we can use Dockerfile

File: `Dockerfile`

```
FROM ruby:2.7

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev imagemagick
RUN gem install bundler

WORKDIR /demo_app
COPY . .
```

You can build and list this image for testing purposes  
`docker build -t demo_app_api_image .`  
`docker image ls`

File: `docker-compose.yml`

```yaml
rack:
  container_name: "hexa_rack"
  depends_on:
    - postgres
    - sidekiq
  build: .
  ports:
    - 3000:3000
  environment:
    - REDIS_URL=redis://redis:6379/0
    - DATABASE_URL=postgres://postgres:@postgres:5432/
  command: bundle exec rackup -I lib -p 3000
```

## Permissions problems
https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue

## Docker login

dice que quizas para poder bajar imagenes de docker hub te tenes que loguear ???
