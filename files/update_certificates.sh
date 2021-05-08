#!/bin/sh
cd /etc/letsencrypt/live || exit 1
TARGET=/certificates
TRAEFIK_CFG_FINAL=${TARGET}/traefik/traefik.toml
TRAEFIK_CFG=${TARGET}/traefik.toml.tmp
CERTIFICATES=`ls */fullchain.pem | sed 's/\/fullchain.pem//'`

if [ ! -d ${TARGET}/certificates ]; then
	mkdir -p ${TARGET}/certificates
fi

if [ ! -d ${TARGET}/traefik ]; then
	mkdir -p ${TARGET}/traefik
fi

cat > ${TRAEFIK_CFG} <<EOF
[tls]
EOF

for certificate in ${CERTIFICATES}; do
	echo "== Manage ${certificate}"
	cat ${certificate}/fullchain.pem > ${TARGET}/certificates/${certificate}_fullchain.pem
	cat ${certificate}/privkey.pem   > ${TARGET}/certificates/${certificate}_privkey.pem
	echo ""                                                        >> ${TRAEFIK_CFG}
	echo "  [[tls.certificates]]"                                    >> ${TRAEFIK_CFG}
	echo "    certFile = \"${TARGET}/certificates/${certificate}_fullchain.pem\"" >> ${TRAEFIK_CFG}
	echo "    keyFile = \"${TARGET}/certificates/${certificate}_privkey.pem\""    >> ${TRAEFIK_CFG}
done

cat ${TRAEFIK_CFG} > ${TRAEFIK_CFG_FINAL}
