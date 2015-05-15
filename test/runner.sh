#!/bin/bash
set -e

function abort()
{
	echo "$@"
	exit 1
}

function cleanup()
{
	echo " --> Stopping container"
	docker stop $ID >/dev/null
	docker rm $ID >/dev/null
}

PWD=`pwd`

echo " --> Starting container"
ID=`docker run -d -v $PWD/test:/test $NAME:$VERSION /sbin/my_init`
sleep 1

echo " --> Obtaining IP"
IP=`docker inspect $ID | grep IPAddress | sed -e 's/.*: "//; s/".*//'`
if [[ "$IP" = "" ]]; then
	abort "Unable to obtain container IP"
fi

trap cleanup EXIT

echo " --> Logging into container and running tests"
sleep 1 # Give container some more time to start up.
docker exec $ID /bin/bash /test/test.sh
