#!/bin/bash

LDAP_NAME=${LDAP_NAME:-openldap}
LDAP_VOLUME=${LDAP_VOLUME:-openldap-volume}

if [ -n "$(docker ps -a | grep ${LDAP_NAME})" ]; then
docker stop ${LDAP_NAME}
docker rm -v ${LDAP_NAME}
docker rm -v ${LDAP_VOLUME}
fi
