#!/bin/bash -e

LDIF_DIR=/container/service/slapd/assets/test
BASE_LDIF=base.ldif

#Convert FQDN to LDAP base DN
SLAPD_TMP_DN=".${LDAP_DOMAIN}"
while [ -n "${SLAPD_TMP_DN}" ]; do
SLAPD_DN=",dc=${SLAPD_TMP_DN##*.}${SLAPD_DN}"
SLAPD_TMP_DN="${SLAPD_TMP_DN%.*}"
done
SLAPD_DN="${SLAPD_DN#,}"

#Create base.ldif
sed -e "s/{SLAPD_DN}/${SLAPD_DN}/g" ${LDIF_DIR}/${BASE_LDIF}.template > ${LDIF_DIR}/${BASE_LDIF}
sed -i "s/{ADMIN_UID}/$1/g" ${LDIF_DIR}/${BASE_LDIF}
sed -i "s/{ADMIN_EMAIL}/$3/g" ${LDIF_DIR}/${BASE_LDIF}

#Import accounts
ldapadd -f ${LDIF_DIR}/${BASE_LDIF} -x -D "cn=admin,${SLAPD_DN}" -w ${LDAP_ADMIN_PASSWORD}
ldappasswd -x -D "cn=admin,${SLAPD_DN}" -w ${LDAP_ADMIN_PASSWORD} -s $2 \
"uid=$1,ou=accounts,${SLAPD_DN}"

rm -rf ${LDIF_DIR}/${BASE_LDIF}
