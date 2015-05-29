#!/bin/bash

CONFIG_FILE="$HOME/.easydns"

if [[ -e $CONFIG_FILE ]]; then
    source $CONFIG_FILE

    if [ -z "$DNSENTRY" ]; then
        echo "Must specify DNSENTRY"
        exit 1
    elif [ -z "$USERNAME" ]; then
        echo "Must specify USERNAME"
        exit 1
    elif [ -z "$PASSWORD" ]; then
        echo "Must specify PASSWORD"
        exit 1
    fi
else
    echo "Must have config at $CONFIG_FILE"
    exit 1
fi

MYIP="$(curl -ss canhazip.com)"
BASEAPI="https://members.easydns.com/dyn/dyndns.php"

curl -ss --user $USERNAME:$PASSWORD -X GET $BASEAPI?hostname=$DNSENTRY&myip=$MYIP > /dev/null 1>&2

