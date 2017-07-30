# docker-known

A Docker image for [Known](https://withknown.com/), the social publishing platform. This image installs Known v0.9.9.

This is a multi-process image based on the official [php:fpm-alpine](https://hub.docker.com/_/php/) image. This image includes the necessary PHP extensions for running Known; just link your database container.

PHP fastcgi is exposed on port `9000` running the default configuration, while nginx is exposed on the standard HTTP port `80` using the configuration provided by Known.

## Quick start

```bash
docker run -d --name db -v /some/host/dir:/var/lib/mysql -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_DATABASE=known -e MYSQL_USER=known_user -e MYSQL_PASSWORD=known_pass mariadb

docker run -d --link mariadb:db -v /some/host/dir:/Uploads -p 8080:80 richardcarls/known
```

## Configuration

The image comes with a default configuration for Known:

```INI
# config.ini
database = MySQL
dbhost = db
dbname = known
dbuser = known_user
dbpass = known_pass
uploadpath = /Uploads/
sessionname = known
```

Configuration settings can be set via environment variables.

- `KNOWN_DATABASE`
- `KNOWN_DBHOST`
- `KNOWN_DBNAME`
- `KNOWN_DBUSER`
- `KNOWN_DBPASS`
- `KNOWN_UPLOADPATH`
- `KNOWN_SESSIONNAME`

## Database

Known requires a database; link your Known container to a running database container. The default configuration expects MySQL or MariaDB at the host `db`. This image does not create the initial database or database user, it has to exist at runtime.

```bash
docker run -d --link some-mysql:db -p 8080:80 richardcarls/known
```

### SQLite

SQLite3 can be used instead of a separate database container. Set `KNOWN_DATABASE=Sqlite`. You will also want to set `KNOWN_DBNAME` to the name and path of the database file (ie: `/data/sqlite.db`) and ensure it is persisted outside the container.

```bash
docker run -d -v /some/host/dir:/data -e KNOWN_DATABASE=Sqlite -e KNOWN_DBNAME=/data/sqlite.db -p 8080:80 richardcarls/known
```

### PostgreSQL

[PostgreSQL](https://www.postgresql.org/) can also be used with Known (though I cannot get it to work, personally). Set `KNOWN_DATABASE=Postgres` and link your running PostgreSQL container to use this configuration.

```bash
docker run -d --link some-pgsql:db -e KNOWN_DATABASE=Postgres -p 8080:80 richardcarls/known
```

### MongoDB

[MongoDB](https://www.mongodb.com/) might also work but its use is deprecated at this time. Set `KNOWN_DATABASE=MongoDB` to use this configuration.

## Uploads

Known stores uploaded media in the specified `uploadpath` (`/Uploads/` by default). You can specify a Docker volume or host mount here to preserve uploads.

```bash
docker run -d --link some-mysql:db -v /some/host/dir:/Uploads -p 8080:80 richardcarls/known
```

Make sure your `uploadpath` is readable and writeable by the `www-data` (uid 33) user. This image does not modify ownership of mounted volumes.

## Usage notes

### SSL

You will have to provide a custom `nginx.conf` if you wish to serve over https directly, or use a reverse proxy container like [traefik](https://hub.docker.com/_/traefik/).

### Mail

This image does not have a mail server, so you may wish to configure Known with a 3rd party SMTP server for things like sending invites to users.

### Themes and plugins

Known comes bundled with a selection of great themes and plugins. You can substitute your own by mounting volumes to `/var/www/html/Themes` and `/var/www/html/IdnoPlugins`.
