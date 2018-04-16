#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

# Node is not supported in initial version
#NODE_NAME=${NODENAME-IIBV10NODE}
BASE_DIR=~/workspace/runtimes
SERVER_NAME=${SERVERNAME-default}
#WORKINGDIR_NAME=${WORKINGDIR:-"~/aceruntimes/defaultrt"}
WORKINGDIR_NAME=$BASE_DIR/$SERVERNAME
echo "Runtime directory set to : " $WORKINGDIR_NAME

start()
{
	echo "----------------------------------------"
        /opt/ibm/ace-11.0.0.0/ace version
	echo "----------------------------------------"
	      #node node supported in this release
        #NODE_EXISTS=`mqsilist | grep $NODE_NAME > /dev/null ; echo $?`
  if [ ! -d "$WORKINGDIR_NAME" ]; then
		      # Control will enter here if $DIRECTORY doesn't exist.
					echo "----------------------------------------"
		      echo "Runtime directory doesnt exist....."
					echo "Creating runtime directory : " $WORKINGDIR_NAME
					mkdir -p $BASE_DIR
					mqsicreateworkdir $WORKINGDIR_NAME
					echo "----------------------------------------"
          echo "----------------------------------------"
					#echo "Starting syslog"
          #sudo /usr/sbin/rsyslogd
          #echo "Starting Integration Server $SERVER_NAME"
          #IntegrationServer --name $SERVERNAME --work-dir $WORKINGDIR_NAME &
          echo "----------------------------------------"
          echo "----------------------------------------"
					shopt -s nullglob
          for f in /tmp/bars/* ; do
            echo "Deploying $f ..."
						mqsibar -a $f -c -w $WORKINGDIR_NAME
          done
          echo "----------------------------------------"
          echo "----------------------------------------"
					echo "Starting syslog"
          sudo /usr/sbin/rsyslogd
					echo "Restarting Integration Server"
					ps axf | grep IntegrationServer | grep -v grep | awk '{print "kill -9 " $1}' | sh
					IntegrationServer --name $SERVERNAME --work-dir $WORKINGDIR_NAME
				else
					echo "Directory somehow exists"
	fi


}

monitor()
{
	echo "----------------------------------------"
	echo "Running - stop container to exit"
	# Loop forever by default - container must be stopped manually.
	# Here is where you can add in conditions controlling when your container will exit - e.g. check for existence of specific processes stopping or errors beiing reported
	while true; do
		sleep 1
	done
}

#license files do not exist hence commented
ace-license-check.sh
start
trap stop SIGTERM SIGINT
monitor
