FROM ubuntu:24.04

#ENV RUNNER_VER="2.317.0"

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
WORKDIR /home/ubuntu

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip jq curl tar zip unzip libicu-dev liblttng-ust-dev libnuma-dev liburcu-dev libicu74 && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN mkdir /home/ubuntu/actions-runner && \
    cd /home/ubuntu/actions-runner && \
    export RUNNER_VER=$(curl -sL https://raw.githubusercontent.com/actions/runner/main/src/runnerversion) && \
    curl -o actions-runner-linux-x64-$RUNNER_VER.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VER/actions-runner-linux-x64-$RUNNER_VER.tar.gz && \
    tar xzf ./actions-runner-linux-x64-$RUNNER_VER.tar.gz && \
    rm -f tar xzf ./actions-runner-linux-x64-$RUNNER_VER.tar.gz && \
    chown ubuntu:ubuntu -R /home/ubuntu
# install some additional dependencies

COPY --chown=ubuntu:ubuntu ./init.sh /home/ubuntu/actions-runner/init.sh

RUN chmod +x /home/ubuntu/actions-runner/init.sh

USER ubuntu

# set the entrypoint to the init.sh script
ENTRYPOINT ["/bin/bash", "-c", "/home/ubuntu/actions-runner/init.sh"]
