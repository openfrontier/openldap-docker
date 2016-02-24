#!/bin/bash -e

LDAP_NAME=${LDAP_NAME:-openldap}
LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD:-$1}
LDAP_DOMAIN=${LDAP_DOMAIN:-$2}
LDAP_IMAGE_NAME=${LDAP_IMAGE_NAME:-osixia/openldap}
DOCKER_NET=${DOCKER_NET:-demo}

#Start openldap
docker run \
--name ${LDAP_NAME} \
-p 389:389 \
-e LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD} \
-e LDAP_DOMAIN=${LDAP_DOMAIN} \
-e LDAP_TLS=false \
--net=${DOCKER_NET} \
-d ${LDAP_IMAGE_NAME}

while [ -z "$(docker logs ${LDAP_NAME} 2>&1 | tail -n 4 | grep 'slapd starting')" ]; do
    echo "Waiting openldap ready."
    sleep 1
done

