#!/bin/sh


if [ ! -f /etc/asterisk/pjsip.conf ]; then
    echo "Creating pjsip.conf"
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

    # PJSIP configuration
    touch /etc/asterisk/pjsip.conf
    chown asterisk:asterisk /etc/asterisk/pjsip.conf
    chmod 640 /etc/asterisk/pjsip.conf

    cat > /etc/asterisk/pjsip.conf << EOF
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:$SIP_PORT

[fritzbox_auth]
type=auth
auth_type=userpass
password=$SIP_PASSWORD
username=$SIP_USERNAME

[fritzbox]
type=registration
transport=transport-udp
outbound_auth=fritzbox_auth
server_uri=sip:$SIP_HOST
client_uri=sip:$SIP_USERNAME@$SIP_HOST
retry_interval=60

[fritzbox]
type=aor
contact=sip:$SIP_HOST

[fritzbox]
type=endpoint
transport=transport-udp
context=public
disallow=all
allow=ulaw
allow=alaw
outbound_auth=fritzbox_auth
aors=fritzbox
from_user=$SIP_FROM_USER

[fritzbox]
type=identify
endpoint=fritzbox
match=$SIP_HOST
EOF
    echo "Created pjsip.conf"
fi

exec "$@"