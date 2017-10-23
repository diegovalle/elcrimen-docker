FROM ubuntu:14.04
MAINTAINER Diego Valle-Jones

# Add ansible configuration
ADD ansible/ /etc/ansible/

WORKDIR /etc/ansible

# Install Ansible
RUN apt-get -y update &&  \
    apt-get -y upgrade &&  \
    apt-get -q -y --no-install-recommends install python-yaml \
               python-jinja2 python-httplib2 python-keyczar \
               python-paramiko python-setuptools \
               python-pkg-resources git python-pip &&  \
    mkdir -p /etc/ansible/ &&  \
    pip install ansible==2.1 &&  \
    ansible-playbook -c local playbook.yml && \
    cp /root/new.crimenmexico/downloader/tabula-java/* /root/ &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Expose port 22 and 80
# EXPOSE 22

ENTRYPOINT ["/bin/bash"]