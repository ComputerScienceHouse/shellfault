#!/bin/bash

_ACCESS_TOKEN=$(
  curl https://sso.csh.rit.edu/auth/realms/csh/protocol/openid-connect/token \
    --basic -u shellfault:$SHELLFAULT_SERVICE_TOKEN \
    -d 'grant_type=client_credentials' \
    -d 'audience=quotefault' | jq -r .access_token
)

_GET_QUOTES="curl https://quotefault.csh.rit.edu/storage -H 'Accept: application/json' -H 'Authorization: Bearer $_ACCESS_TOKEN'"

sh -c "$_GET_QUOTES" | \
  TZ=America/New_York jq -j '[.quotes | .[] | (
    "\"" + .quote +
    "\"\n\t\t-- " + .speaker +
    ", (Submitted by: " + .submitter + "), " +
    (.time | sub("\\+00:00$"; "Z") | fromdateiso8601 | strflocaltime("%F %T")) + "\n%"
  )] | sort | join("\n")' > /etc/fortune/csh

strfile /etc/fortune/csh
