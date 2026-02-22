#!/bin/sh

if [ ! -f /etc/asterisk/indications.conf ]; then
   echo "Creating /etc/asterisk/indications.conf "
   if [ -z "$COUNTRY" ]; then
      COUNTRY=de
   fi
   cat << EOF > /etc/asterisk/indications.conf
[general]
country=$COUNTRY       ; default location
[de]
description = Germany
ringcadance = 1000,4000
dial = 425
ring = 425/1000,0/4000
busy = 425/480,0/480
congestion = 425/480,0/480
callwaiting = 425/2000,0/6000
dialrecall = 425/500,0/500,425/500,0/500,425/500,0/500,1600/100,0/900
record = 1400/500,0/15000
info = 950/330,0/200,1400/330,0/200,1800/330,0/1000
EOF
else
  echo "/etc/asterisk/indications.conf already exists"
fi

if [ ! -f /etc/asterisk/phoneprov.conf ]; then
    echo "Creating /etc/asterisk/phoneprov.conf"
    if [ -z "$SIP_HOST" ]; then
        echo "SIP_HOST not set"
        exit 1
    fi

    sed "s/@@@SIP_HOST@@@/$SIP_HOST/g" /etc/asterisk/phoneprov.conf.template >  /etc/asterisk/phoneprov.conf
fi

if [ ! -f /etc/asterisk/rtp.conf ]; then

   if [ -z "$RTP_START_PORT" ]; then
     RTP_START_PORT=10000
   fi
   if [ -z "$RTP_END_PORT" ]; then
     RTP_END_PORT=20000
   fi
   cat << EOF > /etc/asterisk/rtp.conf
[general]
rtpstart=$RTP_START_PORT
rtpend=$RTP_END_PORT
EOF
fi

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
local_net=${SIP_LOCAL_NET} ; Internes Netz
external_media_address=${SIP_EXTERN_HOST} ; Eure öffentliche IP
external_signaling_address=${SIP_EXTERN_HOST}

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
contact=sip:${SIP_HOST}:${SIP_PORT}
qualify_frequency=60

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
match=${SIP_HOST}

EOF
    echo "Created pjsip.conf"
fi

exec "$@"