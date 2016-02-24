#!/bin/bash -e

LDAP_NAME=${LDAP_NAME:-openldap}

if [ -n "$(docker ps -a | grep ${LDAP_NAME})" ]; then
docker -H ${SWARM_URL} stop ${LDAP_NAME}
docker -H ${SWARM_URL} rm -v ${LDAP_NAME}
fi
