#! /bin/sh
### BEGIN INIT INFO
# Provides:          ceph_exporter
# Required-Start:    $remote_fs $time
# Required-Stop:     umountnfs $time
# X-Stop-After:      sendsigs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: enhanced syslogd
# Description:       Rsyslog is an enhanced multi-threaded syslogd.
#                    It is quite compatible to stock sysklogd and can be 
#                    used as a drop-in replacement.
### END INIT INFO

#
# Author: Michael Biebl <biebl@debian.org>
#

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="enhanced ceph_exporter"
NAME=ceph_exporter

#CEPH_EXPORTERD=ceph_exporterd
CEPH_EXPORTERD=ceph_exporter
DAEMON=/usr/local/bin/ceph_exporter
#PIDFILE=/var/run/ceph_exporterd.pid
PIDFILE=/var/run/ceph_exporter.pid

SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Define LSB log_* functions.
. /lib/lsb/init-functions

do_start()
{
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   other if daemon could not be started or a failure occured
	#start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- $CEPH_EXPORTERD_OPTIONS >/dev/null &
	start-stop-daemon --start --quiet --pidfile $PIDFILE  -p $PIDFILE  --exec $DAEMON -- $CEPH_EXPORTERD_OPTIONS >/dev/null 2>&1 &
	PIDID=$(ps -ef | grep "$DAEMON" | grep -v grep | awk '{print$2}');
	echo $PIDID > $PIDFILE
}

do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   other if daemon could not be stopped or a failure occurred
	PIDID=$(cat $PIDFILE)
	kill -9 $PIDID
}

#
# Tell ceph_exporterd to close all open files
#
do_rotate() {
	start-stop-daemon --stop --signal HUP --quiet --pidfile $PIDFILE --exec $DAEMON
}

create_xconsole() {
	XCONSOLE=/dev/xconsole
	if [ "$(uname -s)" != "Linux" ]; then
		XCONSOLE=/run/xconsole
		ln -sf $XCONSOLE /dev/xconsole
	fi
	if [ ! -e $XCONSOLE ]; then
		mknod -m 640 $XCONSOLE p
		chown root:adm $XCONSOLE
		[ -x /sbin/restorecon ] && /sbin/restorecon $XCONSOLE
	fi
}

sendsigs_omit() {
	OMITDIR=/run/sendsigs.omit.d
	mkdir -p $OMITDIR
	ln -sf $PIDFILE $OMITDIR/ceph_exporter
}

case "$1" in
  start)
	#if init_is_upstart; then
	#	exit 1
	#fi
	log_daemon_msg "Starting $DESC" "$CEPH_EXPORTERD"
	create_xconsole
	do_start
	case "$?" in
		0) sendsigs_omit
		   log_end_msg 0 ;;
		1) log_progress_msg "already started"
		   log_end_msg 0 ;;
		*) log_end_msg 1 ;;
	esac

	;;
  stop)
	#if init_is_upstart; then
	#	exit 0
	#fi
	log_daemon_msg "Stopping $DESC" "$CEPH_EXPORTERD"
	do_stop
	case "$?" in
		0) log_end_msg 0 ;;
		1) log_progress_msg "already stopped"
		   log_end_msg 0 ;;
		*) log_end_msg 1 ;;
	esac

	;;
  rotate)
	log_daemon_msg "Closing open files" "$CEPH_EXPORTERD"
	do_rotate
	log_end_msg $?
	;;
  restart|force-reload)
	#if init_is_upstart; then
	#	exit 1
	#fi
	$0 stop
	$0 start
	;;
  status)
	status_of_proc -p $PIDFILE $DAEMON $CEPH_EXPORTERD && exit 0 || exit $?
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|rotate|restart|force-reload|status}" >&2
	exit 3
	;;
esac

:
