# judge if env variables are ready
if [[ "${SPARK_HOME}" = "" ]]; then
	source ipython_notebook_spark.bashrc  
fi

PIDFILE="IPYTHON_NOTEBOOK_SERVER_WITH_SPARK_PID.txt"

function start() {
	local pid
	## judge whether the process is running or not
	if [[ -f "${PIDFILE}" ]]; then
		pid=$(cat ${PIDFILE})
		if kill -0 ${pid} > /dev/null 2>&1; then
			echo -e "ipython notebook server with spark is already running ..."
			return 0
		fi
	fi
	## start process
	echo "Going to start ipython notebook server with spark integrated ..."
	filename="notebook-"$(date "+%Y-%m-%d")".txt" 
	echo "Create log file: " $filename
	ipython notebook --profile=pyspark  > $filename 2>&1 &
	## store process pid for later use
	pid=$!
	if [[ -z "${pid}" ]]; then
		echo -e "Start failed ... \nExit now ..."
		return 1
	else
		echo -e "Start success ... \nProcess PID is : "${pid}
		echo ${pid} > ${PIDFILE}
	fi
}

function stop() {
	local pid
	echo "Going to stop ipython notebook server with spark integrated ..."
	## judge whether the process is running or not
    if [[ -f "${PIDFILE}" ]]; then
        pid=$(cat ${PIDFILE})
        if kill -0 ${pid} > /dev/null 2>&1; then
            kill -9 ${pid}
			echo "ipython notebook server with spark stopped ..."
        else
			echo -e "ipython notebook server with spark is not running ..."
		fi
    fi
}

function print_log() {
	filename="notebook-"$(date "+%Y-%m-%d")".txt"
    echo "Print log file: " $filename
	echo -e "-----------------\n\n\n\n"
	tail -f "${filename}"
}

case "${1}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    print_log
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
esac
