# © Copyright IBM Corporation 2018.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM ubuntu:16.04

LABEL maintainer "Hany Harraz <h.harraz@gmail.com>"

LABEL "ProductID"="447aefb5fd1342d5b893f3934dfded74" \
      "ProductName"="IBM App Connect Enterprise" \
      "ProductVersion"="11.0.0.0"

# Install curl
RUN apt-get update && \
    apt-get install -y curl rsyslog sudo && \
    rm -rf /var/lib/apt/lists/*
    
# Install ACE V11
RUN mkdir /opt/ibm && mkdir -p /tmp/bars && \
    curl http://10.0.0.1:8080/ace/EAsmbl_image/ace-11.0.0.0.tar.gz | \
    tar -xz --exclude ace-11.0.0.0/tools --directory /opt/ibm && \
    /opt/ibm/ace-11.0.0.0/ace make registry global accept license silently 

# Configure system
RUN echo "ACE_11:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog

# Create user to run as
RUN useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers

# Increase security
RUN sed -i 's/sha512/sha512 minlen=8/'  /etc/pam.d/common-password && \
    sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t1/'  /etc/login.defs && \
    sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/'  /etc/login.defs

# Copy in script files
COPY ace_manage.sh /usr/local/bin/
COPY ace-license-check.sh /usr/local/bin/
COPY ace_env.sh /usr/local/bin/
COPY ./bars/*.bar /tmp/bars
RUN chmod +rx /usr/local/bin/*.sh

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/ace_env.sh
ENV MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1
ENV ODBCINI=/opt/ibm/ace-11.0.0.0//server/ODBC/unixodbc/odbc.ini

# Expose default admin port, http port and Web user interface
#EXPOSE 4414 7800
EXPOSE 7800 7600

USER iibuser

# Set entrypoint to run management script
ENTRYPOINT ["ace_manage.sh"]
