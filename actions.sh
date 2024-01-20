#!/bin/bash

#Add repo & token via env
#GIT_ORG=$GIT_ORG
OWNER=$OWNER
REPO=$REPO
ACCESS_TOKEN=$ACCESS_TOKEN
LABEL=$RUNNER_LABEL
#check Runner Name, and generate if not
RUNNER_NAME=${RUNNER_NAME:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)}

#RUNNER_TOKEN=$(curl -sX POST -H "Authorization: token $TOKEN" https://api.github.com/orgs/$GIT_ORG/actions/runners/registration-token | jq .token --raw-output)

RUNNER_TOKEN_FILE="/home/ubuntu/actions-runner/runner_token.txt"
if [ -s "$RUNNER_TOKEN_FILE" ]; then
    # File exists, import its content to RUNNER_TOKEN
    RUNNER_TOKEN=$(<"$RUNNER_TOKEN_FILE")
else
    RUNNER_TOKEN=$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$OWNER/$REPO/actions/runners/registration-token | jq .token --raw-output)
    echo "$RUNNER_TOKEN" > "$RUNNER_TOKEN_FILE"
fi

cd /home/ubuntu/actions-runner

echo "Token: $RUNNER_TOKEN"

#./config.sh remove --unattended --token "${RUNNER_TOKEN}" --name "$RUNNER_NAME"

./config.sh --url "https://github.com/$OWNER/$REPO" --token "$RUNNER_TOKEN" --name "$RUNNER_NAME" --unattended --label "ubuntu:latest $LABEL"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "$RUNNER_TOKEN" --name "$RUNNER_NAME"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
