#!/bin/bash
nssdir="$(dirname $0)/nss/ipsec.d"
mydir="$(dirname $0)"
mkdir -p ${nssdir}
rm -f ${nssdir}/*
cp ${mydir}/../CARoot.crt ${nssdir}/
cp ${mydir}/../CARoot.key ${nssdir}/
ipsec initnss --nssdir ${nssdir}
echo "dsadasdasdasdadasdasdasdasdsadfwerwerjfdksdjfksdlfhjsdk" > ${nssdir}/cert.noise
#certutil -W -d sql:${nssdir} << EOF
#chaofei
#chaofei
#EOF
certutil -d sql:${nssdir} -A -t "C,C,C" -n CARootCrt -s "CN=CARootCrt" -v 12 -i ${mydir}/../CARoot.crt
#certutil -S -k rsa -n cacert1 -s "CN=cacert1" -v 12 -d . -t "C,C,C" -x -d sql:${nssdir} -z ${nssdir}/cert.noise
certutil -S -k rsa -n cacert1 -s "CN=cacert1" -v 12 -d . -t "C,C,C" -x -d sql:${nssdir} -z ${nssdir}/cert.noise
#pk12util -o ${nssdir}/cacert1.p12 -n cacert1 -d sql:${nssdir}
certutil -S -k rsa -c cacert1 -n usercert1 -s "CN=usercert1" -v 12 -t "u,u,u" -d sql:${nssdir} -z ${nssdir}/cert.noise
#certutil -S -k rsa -c CARootCrt -n usercert1 -s "CN=usercert1" -v 12 -t "u,u,u" -d sql:${nssdir} -z ${nssdir}/cert.noise
sleep 3
#certutil -S -k rsa -c CARootCrt -n usercert2 -s "CN=usercert2" -v 12 -t "u,u,u" -d sql:${nssdir} -z ${nssdir}/cert.noise
certutil -S -k rsa -c cacert1 -n usercert2 -s "CN=usercert2" -v 12 -t "u,u,u" -d sql:${nssdir} -z ${nssdir}/cert.noise
certutil -L -d sql:${nssdir}
