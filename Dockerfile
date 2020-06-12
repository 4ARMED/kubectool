FROM jpetazzo/nsenter as nsenter
FROM ubuntu:18.04

ARG CLOUD_SDK_VERSION=293.0.0
ARG KUBELETMEIN_VERSION=0.6.5
ARG CONSUL_VERSION=1.6.1
ARG VAULT_VERSION=1.2.3
ARG HELM_VERSION=2.14.3
ARG ETCD_VERSION=v3.4.1
ARG GOLANG_VERSION=1.14.4
ARG METACREDS_VERSION=0.1.1

ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV KUBELETMEIN_VERSION=$KUBELETMEIN_VERSION
ENV CONSUL_VERSION=$CONSUL_VERSION
ENV VAULT_VERSION=$VAULT_VERSION
ENV HELM_VERSION=$HELM_VERSION
ENV ETCD_VERSION=$ETCD_VERSION
ENV GOLANG_VERSION=$GOLANG_VERSION
ENV METACREDS_VERSION=$METACREDS_VERSION

COPY --from=nsenter /nsenter /usr/local/bin/nsenter

ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get -yqq update \
    && apt-get install -y \
        apt-transport-https \
        curl \
        dnsutils \
        gcc \
        git \
        gnupg \
        groff \
        host \
        iproute2 \
        jq \
        lft \
        nfs-common \
        nmap \
        openssh-client \
        python \
        python-pip \
        python-dev \
        python-setuptools \
        vim \
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

RUN curl -sL https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

RUN curl -sL https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz | tar xz -f - -C /usr/local/bin etcd-${ETCD_VERSION}-linux-amd64/etcdctl --strip-components=1

RUN curl -sL https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar xz -f - -C /usr/local

RUN printf "\nexport PATH=$PATH:/usr/local/go/bin:$HOME/go/bin\n" >> /etc/bash.bashrc

RUN curl -sL https://github.com/4ARMED/metacreds/releases/download/v${METACREDS_VERSION}/metacreds_${METACREDS_VERSION}_linux_amd64 -o /usr/local/bin/metacreds && \
    chmod +x /usr/local/bin/metacreds

CMD ["bash"]
