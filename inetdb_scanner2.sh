#!/usr/bin/env	bash

curl -sSL https://internetdb.shodan.io/$1 |jq .

