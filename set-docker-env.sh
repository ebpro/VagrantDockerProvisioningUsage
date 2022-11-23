#!/bin/bash

eval `vagrant ssh-config|\
	grep -e HostName -e "User " -e Port -e IdentityFile|\
	sed 's/  /VAGRANT_/'|tr ' ' '='`

export DOCKER_HOST=ssh://vagrant@${VAGRANT_HostName}:${VAGRANT_Port}
ssh-keygen -R "[${VAGRANT_HostName}]:${VAGRANT_Port}"
ssh-keyscan -p "${VAGRANT_Port}" "${VAGRANT_HostName}" >> ~/.ssh/known_hosts

ssh-add $VAGRANT_IdentityFile