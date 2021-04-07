#!/bin/bash

Clear='\033[0m'
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

ARGS="$@"

printError(){
  echo -n -e "$Red$1\n$Clear"
}

printHeader(){
  echo -n -e "$Cyan$1\n$Clear"
}

printResults(){
  echo -n -e "$Blue$1\n\n$Clear"
}

checkIfRoot(){
  [ $(id -u) != 0 ] &&  usage "You must run as root"
}

usage(){
  [ -n "$1" ] && printError "$1"
  echo "Usage: $0 -p process ID"
  echo "  -p, --process   Target process ID"
  echo "Example: $0 -p 4444"
  exit 1
}

getArgs(){
  [ "$#" -lt 2 ] && usage
    while [ "$#" -gt 0 ]; do
      case $1 in
        -p|--process) PID="$2"; shift 2;;
        -h|--help) usage ;;
        *) usage "Unknown parameter passed: $1"; shift 2;;
      esac;
    done
  [ -z "$PID" ] && usage "Process ID is not set"
  ! $(ps -p $PID > /dev/null 2>&1) && usage "No process with this id"
}

getCommand(){
  printHeader "Process command"
  printResults "$(ps -p $PID -o command=)"
}

getState(){
  printHeader "Process State"
  printResults "$(cat /proc/$PID/status | grep State: | awk '{print $2$3}')"
}

getCWD(){
  printHeader "Process current working directory"
  printResults "$(pwdx $PID | awk '{print $2}')"
}

getStartTime(){
  printHeader  "Process start time"
  printResults "$(ps -p $PID -o lstart=)"
}

getOwner(){
  printHeader "Process owner"
  printResults "$(ps -p $PID -o user= )"
}

getThreadCount(){
  printHeader "Process Thread Count"
  printResults "$(ls /proc/$PID/task/ | wc -l)"
}

getExe(){
  cp "/proc/$PID/exe" .
  printHeader "Process executable copied to $(pwd)/exe\n"
}

getHash(){
  printHeader "Process executable md5 hash"
  printResults "$(md5sum ./exe | awk '{print $1}')"
  printHeader "Process executable sha1 hash"
  printResults "$(sha1sum ./exe | awk '{print $1}')"
}

getLoadedLibraries(){
  printHeader "Process loaded libraries:"
  printResults "$(cat /proc/$PID/maps | awk '{print $6}' | grep '\.so' | sort | uniq || echo "None")"
}

getNetworkConnections(){
  printHeader "Process current network connections"
  printResults "$(lsof -p $PID -i -a -e /run/user/1000/gvfs -e /run/user/1000/doc || echo "None" )"
}

getOpenedFds(){
  printHeader "Process current opened file descriptors"
  printResults "$(ls -la /proc/$PID/fd | awk '{if ($11) print $11 $12}' || echo "None")"
}

getEnvValues(){
  printHeader "Process environment variables"
  printResults "$(strings /proc/$PID/environ)"
}

getKernelStack(){
  printHeader "Process kernal stack"
  printResults "$(cat /proc/$PID/stack | awk '{print $2}')"
}

getChildrenProcesses(){
  printHeader "Children processes"
  [ $(ps --ppid $PID --no-headers | wc -l) -ne 0 ] && printResults "$(pstree -p $PID)" || printResults "None"
}

checkIfRoot
getArgs $ARGS
getCommand
getState
getCWD
getStartTime
getOwner
getThreadCount
getExe
getHash
getLoadedLibraries
getNetworkConnections
getOpenedFds
getEnvValues
getKernelStack
getChildrenProcesses
