#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown (retry later)

if [ ! -f jobid ];then
	echo "no jobid - not yet submitted?"
	exit 1
fi

jobid=`cat jobid`
if [ -z $jobid ]; then
	echo "jobid is empty.. failed to submit?"
	exit 3
fi

jobstate=`qstat -f $jobid | grep job_state | cut -b17`
if [ -z $jobstate ]; then
	echo "Job removed before completing - maybe timed out?"
	exit 2
fi

case "$jobstate" in
Q)
	showstart $jobid | grep start
	exit 0
	;;
R)
	#find last touched *.log
	logfile=$(ls -rt *.log | tail -1)
	tail -1 $logfile
	exit 0
	;;
H)
	echo "Job held.. waiting"
	exit 0
	;;
C)
	exit_status=`qstat -f $jobid | grep exit_status | cut -d'=' -f2 | xargs`
	if [ $exit_status -eq 0 ]; then	
		echo "finished with code 0"
		exit 1
	else
		echo "finished with code $exit_status"
		exit 2
	fi
	;;
*)	
	echo "unknown job status $jobstate"
	exit 2
	;;

esac
	