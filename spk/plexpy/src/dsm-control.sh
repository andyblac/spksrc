#!/bin/sh

# Package
PACKAGE="plexpy"
DNAME="plexpy"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PYTHON_DIR="/usr/local/python"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/env/bin:${PYTHON_DIR}/bin:${PATH}:/usr/syno/bin"
USER="plexpy"
PYTHON="${INSTALL_DIR}/env/bin/python"
plexpy="${INSTALL_DIR}/var/plexpy/PlexPy.py"
HOME_DIR="/var/services/homes/${USER}"
DATA_DIR="${HOME_DIR}/"
PID_FILE="${HOME_DIR}/plexpy.pid"
LOG_FILE="${HOME_DIR}/logs/plexpy.log"


start_daemon ()
{
    su ${USER} -s /bin/sh -c "PATH=${PATH} plexpy_DATA=${DATA_DIR} ${PYTHON} ${plexpy} --daemon --datadir ${DATA_DIR}"
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20 || kill -9 `cat ${PID_FILE}`
    rm -f ${PID_FILE}
}

daemon_status ()
{
    ps -aux | grep -v "grep" | grep plexpy > ${PID_FILE}
    if [ -f ${PID_FILE} ] && kill -0 `cat ${PID_FILE}` > /dev/null 2>&1; then
        return
    fi
    rm -f ${PID_FILE}
    return 1
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
        else
            echo Starting ${DNAME} ...
            start_daemon
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
        else
            echo ${DNAME} is not running
        fi
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo ${LOG_FILE}
        ;;
    *)
        exit 1
        ;;
esac
