#!/bin/bash

if [ ! -f .env ]; then
    echo "Please create a .env file with USERNAME/PASSWORD"

    cat << EOF
USERNAME='...'
PASSWORD='...'
EOF

    exit 1
fi

( source .env && docker compose -f compose-spec up )
#USERNAME=ptkarypidis docker compose -f compose-spec up

