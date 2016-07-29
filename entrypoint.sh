#!/bin/bash
#########################################################################
# File Name: entrypoint.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年07月29日 星期五 03时00分31秒
#########################################################################

set -e

rm -f /data/deluged.pid

deluged -d -c /data -L info -l /data/deluged.log &
deluge-web -c /data &
wait
