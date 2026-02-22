#!/bin/sh

usage() {
  echo "Usage: $0 <stoerNr>"
  exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

cat > /tmp/stoerung.$$ << EOF
Channel: Local/start@heizung_melde_kette
Context: stoermeldung
Extension: 10
Setvar: stoerNr=$1
EOF

mv /tmp/stoerung.$$ /var/spool/asterisk/outgoing/