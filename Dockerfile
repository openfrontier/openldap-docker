FROM osixia/openldap
MAINTAINER mengzhaopeng <qiuranke@gmail.com>

COPY base.ldif.template /container/service/slapd/assets/test/
COPY add-ldap-user.sh /container/tool/
