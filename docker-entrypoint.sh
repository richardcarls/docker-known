#!/bin/sh
set -e

# Always run supervisord
if [ "$1" != 'supervisord' ]; then
    set -- supervisord "$@"
fi

# Apply patches
curl -o '#1' -SL https://github.com/idno/Known/commit/{152c801a6252d17777a1e9c25946406a0cd97251.patch}
patch -p1 < 152c801a6252d17777a1e9c25946406a0cd97251.patch

# Render config.ini file
envsubst < config.ini.tpl > config.ini

exec "$@"
