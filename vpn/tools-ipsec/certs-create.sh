#!/bin/sh

MEMBER1=www.member1.com
MEMBER2=www.member2.com
CERT_PATH=$1
FRONT_CLIENT_PATH=$CERT_PATH/front_client
FRONT_SERVER_PATH=$CERT_PATH/front_server
BACKEND_CLIENT_PATH=$CERT_PATH/backend_client
BACKEND_SERVER_PATH=$CERT_PATH/backend_server

if [ ! -d "$FRONT_CLIENT_PATH" ]; then
    mkdir -p $FRONT_CLIENT_PATH
fi
if [ ! -d "$FRONT_SERVER_PATH" ]; then
    mkdir -p $FRONT_SERVER_PATH
fi
if [ ! -d "$BACKEND_CLIENT_PATH" ]; then
    mkdir -p $BACKEND_CLIENT_PATH
fi
if [ ! -d "$BACKEND_SERVER_PATH" ]; then
    mkdir -p $BACKEND_SERVER_PATH
fi

# Create self signature CA cert for front client side, which is from user side to haproxy
CA_SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_user/CN=US-FRONT-CLIENT-CA"
openssl req -new -x509 -nodes -newkey rsa:2048 -days 30 -subj $CA_SUBJECT -keyout $FRONT_CLIENT_PATH/ca.key -out $FRONT_CLIENT_PATH/ca.crt

# Create self signature CA cert for front server side, which is haproxy
CA_SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_haproxy/CN=US-FRONT-SERVER-CA"
openssl req -new -x509 -nodes -newkey rsa:2048 -days 30 -subj $CA_SUBJECT -keyout $FRONT_SERVER_PATH/ca.key -out $FRONT_SERVER_PATH/ca.crt

# Create self signature CA cert for backend client side, which is from haproxy to backend
CA_SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_to_member/CN=US-BACKEND-CLIENT-CA"
openssl req -new -x509 -nodes -newkey rsa:2048 -days 30 -subj $CA_SUBJECT -keyout $BACKEND_CLIENT_PATH/ca.key -out $BACKEND_CLIENT_PATH/ca.crt

# Create self signature CA cert for backend server side, which is the real application running on member instance
CA_SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_member/CN=US-BACKEND-SERVER-CA"
openssl req -new -x509 -nodes -newkey rsa:2048 -days 30 -subj $CA_SUBJECT -keyout $BACKEND_SERVER_PATH/ca.key -out $BACKEND_SERVER_PATH/ca.crt

# Create all sides keys
# front client
openssl genrsa -des3 -passout pass:foobar -out $FRONT_CLIENT_PATH/client_encrypted.key 1024
openssl rsa -passin pass:foobar -in $FRONT_CLIENT_PATH/client_encrypted.key -out $FRONT_CLIENT_PATH/client.key
# front server
openssl genrsa -des3 -passout pass:foobar -out $FRONT_SERVER_PATH/server_encrypted.key 1024
openssl rsa -passin pass:foobar -in $FRONT_SERVER_PATH/server_encrypted.key -out $FRONT_SERVER_PATH/server.key
# backend client
openssl genrsa -des3 -passout pass:foobar -out $BACKEND_CLIENT_PATH/client_encrypted.key 1024
openssl rsa -passin pass:foobar -in $BACKEND_CLIENT_PATH/client_encrypted.key -out $BACKEND_CLIENT_PATH/client.key
# backend server
openssl genrsa -des3 -passout pass:foobar -out $BACKEND_SERVER_PATH/$MEMBER1_encrypted.key 1024
openssl rsa -passin pass:foobar -in $BACKEND_SERVER_PATH/$MEMBER1_encrypted.key -out $BACKEND_SERVER_PATH/$MEMBER1.key
openssl genrsa -des3 -passout pass:foobar -out $BACKEND_SERVER_PATH/$MEMBER2_encrypted.key 1024
openssl rsa -passin pass:foobar -in $BACKEND_SERVER_PATH/$MEMBER2_encrypted.key -out $BACKEND_SERVER_PATH/$MEMBER2.key

# genarate member certificate signing request
SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_user_X/CN=US-FRONT-CLIENT-X"
openssl req -passin pass:foobar -new -nodes -subj $SUBJECT -key $FRONT_CLIENT_PATH/client.key -out $FRONT_CLIENT_PATH/client.csr

SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_haproxy_X/CN=US-FRONT-SERVER-X"
openssl req -passin pass:foobar -new -nodes -subj $SUBJECT -key $FRONT_SERVER_PATH/server.key -out $FRONT_SERVER_PATH/server.csr

SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_to_member_X/CN=US-BACKEND-CLIENT-X"
openssl req -passin pass:foobar -new -nodes -subj $SUBJECT -key $BACKEND_CLIENT_PATH/client.key -out $BACKEND_CLIENT_PATH/client.csr

SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_member_X/CN=${MEMBER1}"
openssl req -passin pass:foobar -new -nodes -subj $SUBJECT -key $BACKEND_SERVER_PATH/$MEMBER1.key -out $BACKEND_SERVER_PATH/$MEMBER1.csr
SUBJECT="/C=NZ/ST=OPENSTACKST/L=OPENSTACKSL/O=OPENSTACKSO/OU=OS_member_Y/CN=${MEMBER2}"
openssl req -passin pass:foobar -new -nodes -subj $SUBJECT -key $BACKEND_SERVER_PATH/$MEMBER2.key -out $BACKEND_SERVER_PATH/$MEMBER2.csr

# sign certificates by self signature CA
openssl x509 -req -days 3650 -in $FRONT_CLIENT_PATH/client.csr -CA $FRONT_CLIENT_PATH/ca.crt -CAkey $FRONT_CLIENT_PATH/ca.key -set_serial 01 -out $FRONT_CLIENT_PATH/client.crt
openssl x509 -req -days 3650 -in $FRONT_SERVER_PATH/server.csr -CA $FRONT_SERVER_PATH/ca.crt -CAkey $FRONT_SERVER_PATH/ca.key -set_serial 01 -out $FRONT_SERVER_PATH/server.crt
openssl x509 -req -days 3650 -in $BACKEND_CLIENT_PATH/client.csr -CA $BACKEND_CLIENT_PATH/ca.crt -CAkey $BACKEND_CLIENT_PATH/ca.key -set_serial 01 -out $BACKEND_CLIENT_PATH/client.crt
openssl x509 -req -days 3650 -in $BACKEND_SERVER_PATH/$MEMBER1.csr -CA $BACKEND_SERVER_PATH/ca.crt -CAkey $BACKEND_SERVER_PATH/ca.key -set_serial 01 -out $BACKEND_SERVER_PATH/$MEMBER1.crt
openssl x509 -req -days 3650 -in $BACKEND_SERVER_PATH/$MEMBER2.csr -CA $BACKEND_SERVER_PATH/ca.crt -CAkey $BACKEND_SERVER_PATH/ca.key -set_serial 01 -out $BACKEND_SERVER_PATH/$MEMBER2.crt

# genarate p12 and pem format cert files

# front client cert with pem format, used by client side request.
cat $FRONT_CLIENT_PATH/client.key > $FRONT_CLIENT_PATH/client.pem
cat $FRONT_CLIENT_PATH/client.crt >> $FRONT_CLIENT_PATH/client.pem

# front client ca cert with p12 format, used by haproxy, will be managed by barbican.
openssl pkcs12 -export -clcerts -inkey $FRONT_CLIENT_PATH/ca.key -in $FRONT_CLIENT_PATH/ca.crt  -passout pass: -out $FRONT_CLIENT_PATH/ca.p12

# front server cert with p12 format, used by haproxy
openssl pkcs12 -export -inkey $FRONT_SERVER_PATH/server.key -in $FRONT_SERVER_PATH/server.crt -certfile $FRONT_SERVER_PATH/ca.crt -passout pass: -out $FRONT_SERVER_PATH/server.p12

# backend client cert with p12 format, used by haproxy
openssl pkcs12 -export -inkey $BACKEND_CLIENT_PATH/client.key -in $BACKEND_CLIENT_PATH/client.crt -certfile $BACKEND_CLIENT_PATH/ca.crt -passout pass: -out $BACKEND_CLIENT_PATH/client.p12
cat $BACKEND_CLIENT_PATH/client.key > $BACKEND_CLIENT_PATH/client.pem
cat $BACKEND_CLIENT_PATH/client.crt >> $BACKEND_CLIENT_PATH/client.pem

# backend server ca cert with p12 format, used by haproxy
openssl pkcs12 -export -clcerts -inkey $BACKEND_SERVER_PATH/ca.key -in $BACKEND_SERVER_PATH/ca.crt  -passout pass: -out $BACKEND_SERVER_PATH/ca.p12

openssl pkcs12 -export -inkey $BACKEND_SERVER_PATH/$MEMBER1.key -in $BACKEND_SERVER_PATH/$MEMBER1.crt -certfile $BACKEND_SERVER_PATH/ca.crt -passout pass: -out $BACKEND_SERVER_PATH/$MEMBER1.p12
openssl pkcs12 -export -inkey $BACKEND_SERVER_PATH/$MEMBER2.key -in $BACKEND_SERVER_PATH/$MEMBER2.crt -certfile $BACKEND_SERVER_PATH/ca.crt -passout pass: -out $BACKEND_SERVER_PATH/$MEMBER2.p12

# backend server cert with pem format, used by server side
cat $BACKEND_SERVER_PATH/$MEMBER1.key > $BACKEND_SERVER_PATH/$MEMBER1.pem
cat $BACKEND_SERVER_PATH/$MEMBER1.crt >> $BACKEND_SERVER_PATH/$MEMBER1.pem
cat $BACKEND_SERVER_PATH/$MEMBER2.key > $BACKEND_SERVER_PATH/$MEMBER2.pem
cat $BACKEND_SERVER_PATH/$MEMBER2.crt >> $BACKEND_SERVER_PATH/$MEMBER2.pem

echo "Succeed!"

