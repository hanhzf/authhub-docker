#!/bin/bash

set -e

# config authhub.yaml
python ${AUTHHUB_ROOT_DIR}/authhub_config.py ${AUTHHUB_CONF_DIR}/authhub.yaml ${MEMCACHE_HOST} ${POSTGRES_HOST} ${POSTGRES_PASS}

# change folder ownership to apache2 default user
chown www-data:www-data -R ${AUTHHUB_ROOT_DIR}
chown www-data:www-data -R ${AUTHHUB_CONF_DIR}
chown www-data:www-data -R ${AUTHHUB_LOG_DIR}

# pip dependencies are installed during docker image build
# in case pip pkgs are updated in source code, pip install
# again when startup
tar zxf ${AUTHHUB_BUILD_DIR}/authhub.tgz -C ${AUTHHUB_ROOT_DIR}
pip install -r ${AUTHHUB_ROOT_DIR}/authhub/requirements.txt

# do not serve default 80 page
rm -rf /etc/apache2/sites-enabled/000-default.conf

if [ "${NEED_INIT_DB}" = "yes" ]; then
  echo "initializing AuthHub database tables ..."
  cd ${AUTHHUB_ROOT_DIR}/authhub/authhub/db/migration
  sed -i "s/AUTHHUB_DB_HOST/${POSTGRES_HOST}/g" alembic.ini
  sed -i "s/AUTHHUB_DB_PASSWORD/${POSTGRES_PASS}/g" alembic.ini
  #mv ${AUTHHUB_ROOT_DIR}/authhub/authhub/db/migration/alembic_migrations/versions/* /tmp/
  alembic revision --autogenerate -m 'init authhub database'
  alembic upgrade head
fi

# start service with supervisor
/usr/bin/supervisord
