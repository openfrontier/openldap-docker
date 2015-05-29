#!/bin/bash

LDAP_NAME=${LDAP_NAME:-openldap}

if [ -n "$(docker ps -a | grep ${LDAP_NAME})" ]; then
docker stop ${LDAP_NAME}
docker rm -v ${LDAP_NAME}
fi
