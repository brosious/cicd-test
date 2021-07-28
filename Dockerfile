

FROM ubuntu 

## install helm

RUN  apt update &&  apt upgrade && \
   apt install curl wget -y  && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

## Install kubectl 
RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update
RUN apt-get install -y kubectl
COPY test.sh /test.sh 

RUN chmod +x /test.sh




RUN wget https://github.com/digitalocean/doctl/releases/download/v1.62.0/doctl-1.62.0-linux-amd64.tar.gz -P /tmp/

RUN tar xzf /tmp/doctl-1.62.0-linux-amd64.tar.gz -C /root/ &&  mv /root/doctl /usr/local/bin 

ARG DIGITALOCEAN_ACCESS_TOKEN
ENV DIGITALOCEAN_ACCESS_TOKEN=$DIGITALOCEAN_ACCESS_TOKEN

ENTRYPOINT ./test.sh
