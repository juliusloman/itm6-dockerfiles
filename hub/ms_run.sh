#!/bin/bash

CANDLEHOME=/opt/IBM/ITM
SILENT_CONFIG="/ms_config.txt"
[ -z "$TEMS" ] && TEMS="TEMS"

trap "setarch $(uname -m) --uname-2.6 ${CANDLEHOME}/bin/itmcmd server stop \"${TEMS}\"" SIGTERM SIGINT SIGHUP

OLDHOSTNAME=$(sed -n -e 's/^default|HOSTNAME|\(.*\)|/\1/p' ${CANDLEHOME}/config/.ConfigData/kmsenv)
OLDTEMS=$(cut -f1 -d'|' ${CANDLEHOME}/config/.ConfigData/kmsenv |grep -v default|tail -n 1)

echo "Renaming TEMS ${OLDTEMS} (Hostname: ${OLDHOSTNAME}) to ${TEMS} (Hostname: ${HOSTNAME})"
# Rename ITM hub
mv /opt/IBM/ITM/tables/${OLDTEMS} /opt/IBM/ITM/tables/${TEMS}
mv /opt/IBM/ITM/config/${OLDHOSTNAME}_ms_${OLDTEMS}.config /opt/IBM/ITM/config/${HOSTNAME}_ms_${TEMS}.config
sed -i -e "s/${OLDTEMS}/${TEMS}/g" /opt/IBM/ITM/config/${HOSTNAME}_ms_${TEMS}.config
sed -i -e "s/\/opt\/IBM\/ITM\/config\/${OLDHOSTNAME}_ms_${OLDTEMS}.config/\/opt\/IBM\/ITM\/config\/${HOSTNAME}_ms_${TEMS}.config/" /opt/IBM/ITM/config/.ConfigData/ConfigInfo
sed -i -e "s/${OLDTEMS}/${TEMS}/;s/${OLDHOSTNAME}/${HOSTNAME}/" /opt/IBM/ITM/config/.ConfigData/kmsenv

# Add runtime configuration properties to silent config file
for e in CMSTYPE FIREWALL NETWORKPROTOCOL BK1NETWORKPROTOCOL BK2NETWORKPROTOCOL BK3NETWORKPROTOCOL BK4NETWORKPROTOCOL BK5NETWORKPROTOCOL HOSTNAME IP6HOSTNAME IPPIPEPORTNUMBER IP6PIPEPORTNUMBER KDC_PARTITIONNAME KDC_PARTITIONFILE IPSPIPEPORTNUMBER IP6SPIPEPORTNUMBER PORTNUMBER IP6PORTNUMBER NETNAME LUNAME LOGMODE AUDIT FTO OKFTO HSNETWORKPROTOCOL BK1HSNETWORKPROTOCOL BK2HSNETWORKPROTOCOL BK3HSNETWORKPROTOCOL BK4HSNETWORKPROTOCOL BK5HSNETWORKPROTOCOL MIRROR IP6MIRROR HSIPPIPEPORTNUMBER HSPORTNUMBER HSNETNAME HSLUNAME HSLOGMODE PRIMARYIP SECURITY TEC_EIF TEC_HOST TEC_PORT WORKFLOW KMS_SECURITY_COMPATIBILITY_MODE;
do
        [[ -n "\$${e}" ]] && echo "${e##*_}=\$${e##*_}" >>${SILENT_CONFIG}
done

# Run silent config file
$CANDLEHOME/bin/itmcmd config -S -t "$TEMS" -p ${SILENT_CONFIG}
setarch $(uname -m) --uname-2.6 ${CANDLEHOME}/bin/itmcmd server start "${TEMS}"
read
setarch $(uname -m) --uname-2.6 ${CANDLEHOME}/bin/itmcmd server stop "${TEMS}"
