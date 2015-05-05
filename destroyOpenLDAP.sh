#!/bin/bash

LDAP_NAME=${LDAP_NAME:-openldap}

docker stop ${LDAP_NAME}
docker rm -v ${LDAP_NAME}