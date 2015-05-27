#!/bin/bash
set -e
LDAP_NAME=${LDAP_NAME:-openldap}
SLAPD_PASSWORD=${SLAPD_PASSWORD:-$1}
SLAPD_DOMAIN=${SLAPD_DOMAIN:-$2}
LDAP_IMAGE_NAME=${LDAP_IMAGE_NAME:-dinkel/openldap}

BASE_LDIF=base.ldif
SLAPD_DOMAIN_DC=`echo ${SLAPD_DOMAIN}|sed 's/\./,dc=/g'`
DC="dc="

sed -e "s/{SLAPD_DOMAIN_DC}/${DC}${SLAPD_DOMAIN_DC}/g" ~/openldap-docker/${BASE_LDIF}.template > ~/openldap-docker/${BASE_LDIF}
sed -i "s/{SLAPD_DOMAIN}/${SLAPD_DOMAIN}/g" ~/openldap-docker/${BASE_LDIF}

docker run \
--name ${LDAP_NAME} \
-p 389:389 \
-e SLAPD_PASSWORD=${SLAPD_PASSWORD} \
-e SLAPD_DOMAIN=${SLAPD_DOMAIN} \
-v ~/openldap-docker/${BASE_LDIF}:/${BASE_LDIF}:ro \
-d ${LDAP_IMAGE_NAME}

sleep 5

docker exec openldap \
ldapadd -f /${BASE_LDIF} -x -D "cn=admin,${DC}${SLAPD_DOMAIN_DC}" -w ${SLAPD_PASSWORD}

docker exec openldap \
ldappasswd -x -D "cn=admin,${DC}${SLAPD_DOMAIN_DC}" -w ${SLAPD_PASSWORD} -s ${SLAPD_PASSWORD} \
"uid=gerrit,ou=accounts,${DC}${SLAPD_DOMAIN_DC}"