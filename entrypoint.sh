#!/bin/sh


if [ ! -f /etc/asterisk/sip.conf ]; then
    echo "Creating sip.conf"
    if [ -z "$SIP_HOST" ]; then
        echo "SIP_HOST not set"
        exit 1
    fi
    if [ -z "$SIP_EXTERN_HOST" ]; then
        echo "SIP_EXTERN_HOST not set"
        exit 1
    fi

    if [ -z "$SIP_LOCAL_NET" ]; then
        echo "SIP_LOCAL_NET not set"
        exit 1
    fi

    if [ -z "$SIP_USERNAME" ]; then
        echo "SIP_USERNAME not set"
        exit 1
    fi

    if [ -z "$SIP_PASSWORD" ]; then
        echo "SIP_PASSWORD not set"
        exit 1
    fi


    if [ -z "$SIP_FROM_USER" ]; then
        SIP_FROM_USER=$SIP_USERNAME
    fi

    if [ -z "$SIP_PORT" ]; then
        SIP_PORT=5060
    fi

    touch /etc/asterisk/sip.conf
    chown asterisk:asterisk /etc/asterisk/sip.conf
    chmod 640 /etc/asterisk/sip.conf

    cat > /etc/asterisk/sip.conf << EOF
[general] 
udpbindaddr=0.0.0.0:$SIP_PORT

externhost=$SIP_EXTERN_HOST
localnet=$SIP_LOCAL_NET

[fritzbox]
type=peer
username=$SIP_USERNAME
fromuser=$SIP_FROM_USER
secret=$SIP_PASSWORD
host=$SIP_HOST
nat=force_rport,comedia
EOF
    echo 
fi

exec "$@"