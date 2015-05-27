#!/bin/bash
set -e
LDAP_NAME=${LDAP_NAME:-openldap}
SLAPD_PASSWORD=${SLAPD_PASSWORD:-$1}
SLAPD_DOMAIN=${SLAPD_DOMAIN:-$2}
LDAP_IMAGE_NAME=${LDAP_IMAGE_NAME:-dinkel/openldap}
GERRIT_ADMIN_UID=${GERRIT_ADMIN_UID:-$3}
GERRIT_ADMIN_PWD=${GERRIT_ADMIN_PWD:-$4}
GERRIT_ADMIN_EMAIL=${GERRIT_ADMIN_EMAIL:-$5}

BASE_LDIF=base.ldif

#Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${SLAPD_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"

#Create base.ldif
sed -e "s/{SLAPD_DN}/${SLAPD_DN}/g" ~/openldap-docker/${BASE_LDIF}.template > ~/openldap-docker/${BASE_LDIF}
sed -i "s/{ADMIN_UID}/${GERRIT_ADMIN_UID}/g" ~/openldap-docker/${BASE_LDIF}
sed -i "s/{ADMIN_PWD}/${GERRIT_ADMIN_PWD}/g" ~/openldap-docker/${BASE_LDIF}
sed -i "s/{ADMIN_EMAIL}/${GERRIT_ADMIN_EMAIL}/g" ~/openldap-docker/${BASE_LDIF}

#Start openldap
docker run \
--name ${LDAP_NAME} \
-p 389:389 \
-e SLAPD_PASSWORD=${SLAPD_PASSWORD} \
-e SLAPD_DOMAIN=${SLAPD_DOMAIN} \
-v ~/openldap-docker/${BASE_LDIF}:/${BASE_LDIF}:ro \
-d ${LDAP_IMAGE_NAME}

while [ -z "$(docker logs ${LDAP_NAME} 2>&1 | tail -n 4 | grep 'slapd starting')" ]; do
    echo "Waiting openldap ready."
    sleep 1
done

#Import accounts
docker exec openldap \
ldapadd -f /${BASE_LDIF} -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD}

docker exec openldap \
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD} -s ${ADMIN_PWD} \
"uid=${ADMIN_UID},ou=accounts,${SLAPD_DN}"
