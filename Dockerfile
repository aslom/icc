FROM ubuntu:14.04

# Build IBM Container Client (ICC) Docker Image - all binaries and isolated environments
MAINTAINER Aleksander Slominski

RUN sudo apt-get update &&\
  DEBIAN_FRONTEND=noninteractive sudo apt-get -y install wget python-software-properties python-pip apt-transport-https

## Docker

RUN sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

RUN sudo sh -c "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list"

RUN sudo apt-get -y update -qq

# install specific version for reproducibility
#RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker-engine
#RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker-engine=1.8.2\*
RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker-engine=1.8.1*

#RUN sudo gpasswd -a ${USER} docker

#sudo docker version

## CF and IC plugin

# install specific version for reproducibility
#RUN wget 'https://cli.run.pivotal.io/stable?release=debian64&source=github' -O /tmp/cf.deb
RUN wget 'https://cli.run.pivotal.io/stable?release=debian64&version=6.12.4&source=github-rel' -O /tmp/cf.deb

RUN DEBIAN_FRONTEND=noninteractive sudo dpkg -i /tmp/cf.deb

#USER docker

# https://www.ng.bluemix.net/docs/containers/container_cli_ice_ov.html#container_cli_ice_dockerfile

#install python, pip, setuptools
#RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python-pip &&
RUN wget https://bootstrap.pypa.io/ez_setup.py -O -| python

#install ice
RUN DEBIAN_FRONTEND=noninteractive sudo wget https://static-ice.ng.bluemix.net/icecli-3.0.zip && pip install icecli-3.0.zip


#ENV REGISTRY localhost:5000/
#ENV HOME=/opt/user # ignored as bash inside container sets it form passwd anyway
#ENV DOCKER_HOST=tcp://api-ice-dev-test.stage1.ng.bluemix.net:8443
#ENV DOCKER_CERT_PATH=/home/icsng/.ice/certs
#ENV DOCKER_TLS_VERIFY=1

RUN useradd -d "/home/icsng" -u 1000 -m -s /bin/bash icsng

ADD icc.sh /
#ADD create-data-env.sh /
ADD env-skel.sh /


USER icsng

# TODO Any way to version plugin???
RUN cf install-plugin http://static-ice.ng.bluemix.net/ibm-containers-linux_x64

#RUN cf plugins

WORKDIR /opt/workdir

#RUN chown -R icsng:icsng

CMD  ["/bin/bash"]
