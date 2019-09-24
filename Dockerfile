FROM ubuntu:18.04

ARG CLOUD_SDK_VERSION=257.0.0
ARG KUBELETMEIN_VERSION=0.6.5
ARG CONSUL_VERSION=1.6.1
ARG VAULT_VERSION=1.2.3
ARG HELM_VERSION=2.14.3
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV KUBELETMEIN_VERSION=$KUBELETMEIN_VERSION
ENV CONSUL_VERSION=$CONSUL_VERSION
ENV VAULT_VERSION=$VAULT_VERSION
ENV HELM_VERSION=$HELM_VERSION

ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get -yqq update \
    && apt-get -yqq dist-upgrade \
    && apt-get install -y \
        apt-transport-https \
        curl \
        dnsutils \
        gcc \
        git \
        gnupg \
        host \
        jq \
        lft \
        nmap \
        openssh-client \
        python \
        python-pip \
        python-dev \
        python-setuptools \
        zip \
    && apt-get clean -yqq

RUN set -x && \
    pip install awscli crcmod && \
    mkdir /root/.aws && \
    echo '[default]\nregion = eu-west-1' > /root/.aws/config

RUN export CLOUD_SDK_REPO="cloud-sdk-stretch" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -yqq && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN curl -sL https://github.com/4ARMED/kubeletmein/releases/download/v${KUBELETMEIN_VERSION}/kubeletmein_${KUBELETMEIN_VERSION}_linux_amd64 -o /usr/local/bin/kubeletmein && \
    chmod +x /usr/local/bin/kubeletmein

RUN curl -sL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip | funzip > /usr/local/bin/vault && \
    chmod +x /usr/local/bin/vault

RUN curl -sL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip | funzip > /usr/local/bin/consul && \
    chmod +x /usr/local/bin/consul

RUN curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xz -f - -C /usr/local/bin linux-amd64/helm --strip-components=1

CMD ["bash"]
