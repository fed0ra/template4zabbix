#!/bin/bash
#Date:          2016-06-06
#Author:        Created by mean
#Mail:          990@qq.com
#Function:      This script is monitor linux service status
#Version:       1.0

jetty_ping_fun(){

	JETTY_STAT_VALUE=''
	ADDR=127.0.0.1
	PRO_PORT=$1
	PRO_NAME=$2
	comm=`/usr/bin/curl -m 5 -s $ADDR:$1/$2/game/test`
	if [ "$comm" = "success" ];then
		JETTY_STAT_VALUE=1
		echo $JETTY_STAT_VALUE
	else
		JETTY_STAT_VALUE=0
		echo $JETTY_STAT_VALUE
	fi
}


main(){
	case $1 in
		jetty_ping)
			jetty_ping_fun $2 $3;
			;;
		*)
			echo $"Usage : $0 {jetty_ping key}"
	esac
}


main $1 $2 $3
