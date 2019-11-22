#!/usr/bin/env bash

LOG_TYPE="VERBOSE"
LOG_VERBOSE_PREFIX="[VERBOSE]"

logVerbose(){
    printf "%s %s \n" "$LOG_VERBOSE_PREFIX" "$1"
}
