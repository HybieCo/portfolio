#!/usr/bin/env sh

tflocal init
tflocal plan
tflocal apply --auto-approve

restapi=$(awslocal apigatewayv2 get-apis | jq -r '.Items[0].ApiId')
curl --location "${restapi}.execute-api.localhost.localstack.cloud:4566/example/test"

tflocal apply -destroy --auto-approve