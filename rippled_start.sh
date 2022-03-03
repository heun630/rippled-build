#!/bin/bash
HOME="/data/ripple/rippled/my_build"
IDENTITY="rippled"              
PID=$HOME/${IDENTITY}.pid
DATADIR=$HOME


LOG=$DATADIR/logs/${IDENTITY}.log
COMMAND=./$IDENTITY

status() {
    echo
    echo "*** Status ***"

    if [ -f ${PID} ]
    then
        echo
        echo "Pid file: $( cat ${PID} ) [${PID}]"
        echo
        ps -ef | grep -v grep | grep $( cat ${PID} )
    else
        echo
        echo "No Pid file"
    fi
}

start() {
    if [ -f ${PID} ]
    then
        echo
        echo "Already started. PID: [$( cat ${PID} )]"
    else
        echo "*** Start ***"
        touch ${PID}
        if sudo nohup ${COMMAND} > ${LOG} & 
        then
            echo $! > ${PID}
            echo "Done."
            echo "$(date '+%Y-%m-%d %X'): Start" >> ${LOG}
        else
            echo "Error..."
            /bin/rm ${PID}
        fi
    fi
}

kill_cmd() {
    SIGNAL=""
    MSG="Killing"
    while true
    do
        LIST=`ps -ef | grep -v grep | grep ${IDENTITY} | grep -w ${USR} | awk '{print $2}'`
        if [ "${LIST}" ]
        then
            echo
            echo "${MSG} ${LIST}"
            echo
            echo ${LIST} | xargs sudo kill ${SIGNAL}
            sleep 2
            SIGNAL="-9"
            MSG="Killing ${SIGNAL}"
            if [ -f ${PID} ]
            then
                /bin/rm ${PID}
            fi
        else
            echo
            echo "All killed..."
            echo
        fi
    done
}

stop() {
    echo "*** Stop ***"

    if [ -f ${PID} ]
    then
        if kill $( cat ${PID} )
        then
            echo "Done."
            echo "$(date '+%Y-%m-%d %X'): STOP" >>${LOG}
            /bin/rm ${PID}
        fi
    else
        echo "No pid file. Already stopped?"
    fi
}

case "$1" in
    'start')
        start
        ;;
    'stop')
        stop
        ;;

    'status')
        status
        ;;
    *)
        echo
        echo "Usage: $0 { start | stop | restart | status }"
        echo
        exit 1
        ;;
esac

exit 0
