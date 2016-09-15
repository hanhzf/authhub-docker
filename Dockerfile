FROM ubuntu:trusty

MAINTAINER FRANK <hanhzf@126.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y\
  python-dev python-pip libpq-dev libffi-dev apache2 supervisor\
  libapache2-mod-wsgi && rm -rf /var/lib/apt/lists/*

ENV NEED_INIT_DB='no'
ENV AUTHHUB_ROOT_DIR=/opt/zen/
ENV AUTHHUB_CONF_DIR=${AUTHHUB_ROOT_DIR}/conf/
ENV AUTHHUB_LOG_DIR=${AUTHHUB_ROOT_DIR}/logs/
ENV PYTHONPATH ${AUTHHUB_ROOT_DIR}/authhub/:${PYTHONPATH}

#ENV MEMCACHE_HOST=127.0.0.1:11211
#ENV POSTGRES_HOST=127.0.0.1
ENV MEMCACHE_HOST=10.70.44.118:11211
ENV POSTGRES_HOST=10.70.44.118

ENV POSTGRES_PASS=zhu88jie

# build volume
ENV AUTHHUB_BUILD_DIR /opt/build/
VOLUME ["/opt/build/"]

# configure apache2
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY files/authhub_site.conf /etc/apache2/sites-enabled/
RUN sed -i "s|AUTHHUB_ROOT_DIR|${AUTHHUB_ROOT_DIR}|g" /etc/apache2/sites-enabled/authhub_site.conf

# configure supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# prepare folder and startup scripts
RUN mkdir -p ${AUTHHUB_ROOT_DIR}
RUN mkdir -p ${AUTHHUB_CONF_DIR}
RUN mkdir -p ${AUTHHUB_LOG_DIR}
COPY authhub_entrypoint.sh ${AUTHHUB_ROOT_DIR}
COPY authhub_config.py ${AUTHHUB_ROOT_DIR}
RUN chmod +x ${AUTHHUB_ROOT_DIR}/authhub_entrypoint.sh

# install pip dependencies
COPY files/requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

ENTRYPOINT ["/opt/zen/authhub_entrypoint.sh"]

EXPOSE 5000
