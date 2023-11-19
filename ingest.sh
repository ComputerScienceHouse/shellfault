#!/bin/bash

_ACCESS_TOKEN=$(
  curl https://sso.csh.rit.edu/auth/realms/csh/protocol/openid-connect/token \
    --basic -u shellfault:"$SHELLFAULT_SERVICE_TOKEN" \
    -d 'grant_type=client_credentials' \
    -d 'scope=openid profile email offline_access' | jq -r .access_token
)

_GET_QUOTES="curl https://quotefault.csh.rit.edu/api/quotes?limit=-1 -H 'Accept: application/json' -H 'Authorization: Bearer $_ACCESS_TOKEN'"

sh -c "$_GET_QUOTES" | TZ=America/New_York jq -j \
  '. | map({
    body: .shards | map("\t\"" + .body + "\" - " + .speaker.cn + " (" + .speaker.uid + ")") | join("\n"),
    submitter: (.submitter.cn + " (" + .submitter.uid + ")"),
    timestamp: ((.timestamp | sub("\\.\\d+$"; "")) + "Z") | fromdate | strflocaltime("%F %T") }
  )[]
  | (.body + "\n\nSubmitted by " + .submitter + " on " + .timestamp + "\n%\n")' > /etc/fortune/csh

strfile /etc/fortune/csh
