#!/bin/bash
#Date:          2016-06-06
#Author:        Created by mean
#Mail:          990@qq.com
#Function:      This script is monitor linux service status
#Version:       1.0

tcp_status_fun(){
	TCP_STAT=$1
	ss -ant | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}' > /tmp/netstat.tmp
	TCP_STAT_VALUR=$(grep "$TCP_STAT" /tmp/netstat.tmp | cut -d ' ' -f2)
	if [ -z $TCP_STAT_VALUR ];then
		TCP_STAT_VALUR=0
	fi
	echo $TCP_STAT_VALUR
}

nginx_status_fun(){
	NGINX_PORT=$1
	NGINX_COMMAND=$2
	HOST="127.0.0.1"

# 检测nginx进程是否存在
	nginx_ping(){
		/sbin/pidof nginx | wc -l 
	}
# 检测nginx性能
	nginx_active(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
	}
	nginx_reading(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
	}
	nginx_writing(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
	}
	nginx_waiting(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
	}
	nginx_accepts(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
	}
	nginx_handled(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
	}
	nginx_requests(){
		/usr/bin/curl "http://$HOST:"$NGINX_PORT"/ngx_status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
	}
	case $NGINX_COMMAND in
		active)
			nginx_active;
			;;
		reading)
			nginx_reading;
			;;
		writing)
			nginx_writing;
			;;
		waiting)
			nginx_waiting;
			;;
		accepts)
			nginx_accepts;
			;;
		handled)
			nginx_handled;
			;;
		requests)
			nginx_requests;
			;;
		nginx_ping)
			nginx_ping;
			;;	
	esac
}

mysql_status_fun(){
        MYSQL_PORT=$1
        MYSQL_COMMAND=$2
	MYSQL_USER='root'
	MYSQL_PWD='password'
	MYSQL_HOST='127.0.0.1'
	MYSQL_SOCK='/data/mysql/3306/mysql.sock'
	MYSQLADMIN='/usr/local/mysql/bin/mysqladmin'
	# 数据连接
	#MYSQL_CONN="${MYSQLADMIN} -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT} -S ${MYSQL_SOCK}"
	MYSQL_CONN="${MYSQLADMIN} -u${MYSQL_USER} -h${MYSQL_HOST} -P${MYSQL_PORT} -S ${MYSQL_SOCK}"
	# 参数是否正确
	if [ $# -ne "2" ];then 
		echo "arg error!" 
	fi

	#检测mysql进程是否存在
        mysql_ping(){
                result=`${MYSQL_CONN} ping | grep -c alive`
                echo $result
        }
	#检测mysql性能
        mysql_Uptime(){
		result=`${MYSQL_CONN} status|cut -f2 -d":"|cut -f1 -d"T"`
		echo $result
        }
        mysql_Com_update(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_update"|cut -d"|" -f3`
		echo $result
        }
        mysql_Slow_queries(){
		result=`${MYSQL_CONN} status |cut -f5 -d":"|cut -f1 -d"O"`
		echo $result
        }
        mysql_Com_select(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_select"|cut -d"|" -f3`
		echo $result
        }
        mysql_Com_rollback(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_rollback"|cut -d"|" -f3`
		echo $result
        }
        mysql_Questions(){
		result=`${MYSQL_CONN} status|cut -f4 -d":"|cut -f1 -d"S"`
		echo $result
        }
        mysql_Com_insert(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_insert"|cut -d"|" -f3`
		echo $result
        }
        mysql_Com_delete(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_delete"|cut -d"|" -f3`
		echo $result
        }
        mysql_Com_commit(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_commit"|cut -d"|" -f3`
		echo $result
        }
        mysql_Bytes_sent(){
		result=`${MYSQL_CONN} extended-status |grep -w "Bytes_sent" |cut -d"|" -f3`
		echo $result
        }
        mysql_Bytes_received(){
		result=`${MYSQL_CONN} extended-status |grep -w "Bytes_received" |cut -d"|" -f3`
		echo $result
        }
        mysql_Com_begin(){
		result=`${MYSQL_CONN} extended-status |grep -w "Com_begin"|cut -d"|" -f3`
		echo $result
        }
# 获取数据
	case $MYSQL_COMMAND in
		Uptime)
			mysql_Uptime;
			;;
		Com_update)
			mysql_Com_update;
			;;
		Slow_queries)
			mysql_Slow_queries;
			;;
		Com_select)
			mysql_Com_select;
			;;
		Com_rollback)
			mysql_Com_rollback;
			;;
		Questions)
			mysql_Questions;
			;;
		Com_insert)
			mysql_Com_insert;
			;;
		Com_delete)
			mysql_Com_delete;
			;;
		Com_commit)
			mysql_Com_commit;
			;;
		Bytes_sent)
			mysql_Bytes_sent;
			;;
		Bytes_received)
			mysql_Bytes_received;
			;;
		Com_begin)
			mysql_Com_begin;
			;;
		mysql_ping)
			mysql_ping;
			;;
		*) 
			echo "Usage:$0 port (Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin|mysql_ping)" 
			;;
esac

}

memcached_status_fun(){
	M_PORT=$1
	M_COMMAND=$2
	echo -e "stats\nquit" | nc 127.0.0.1 "$M_PORT" | grep "STAT $M_COMMAND " | cut -d " " -f 3
}

redis_status_fun(){
	R_PORT=$1
	R_COMMAND=$2
	if [ $R_COMMAND = 'redis_ping' ];then
                REDIS_STAT_VALUE=$(/sbin/pidof redis-server | wc -l)
                echo $REDIS_STAT_VALUE
	else
                #(echo -en "INFO \r\n";sleep 1;) | nc localhost "$R_PORT" > /tmp/redis_"$R_PORT".tmp
                (echo -en "INFO \r\n") | redis-cli -p "$R_PORT" -a pansyGrwl > /tmp/redis_"$R_PORT".tmp
                REDIS_STAT_VALUE=$(grep ""$R_COMMAND":" /tmp/redis_"$R_PORT".tmp | cut -d ":" -f2)
                echo $REDIS_STAT_VALUE
	fi
}

main(){
	case $1 in
		tcp_status)
			tcp_status_fun $2;
			;;
		nginx_status)
			nginx_status_fun $2 $3;
			;;
		memcached_status)
			memcached_status_fun $2 $3;
			;;
		redis_status)
			redis_status_fun $2 $3;
			;;
		mysql_status)
			mysql_status_fun $2 $3;
			;;
		*)
			echo $"Usage : $0 {tcp_status key|memcached_status key|redis_status key|nginx_status key|mysql_status key}"
	esac
}


main $1 $2 $3
