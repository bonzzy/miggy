#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/applyMigrationVersion.sh"
. "$DIR/migrationVersion.sh"
. "$DIR/projectType.sh"
. "$DIR/logEvent.sh"
. "$DIR/fileScripts.sh"

if [[ $(fileExists "${migrationFiles[LATEST]}") -eq 1 ]]; then
    logVerbose "It seems that this is the first time running this script!"
    logVerbose "Initializing the script migration project"
    initMigrationProject
fi

#logVerbose "Migration version: $(currentLocalMigrationVersion)"

version="1.1.0"
#logVerbose "Running migration version: $version"
applyUpMigrationVersion ${version}
#
#if [ $? == 0 ]; then
#    logVerbose "[SUCCESS] Migration version applied"
#    else
#      logVerbose "[ERROR] Migration version not applied"
#fi

#applyDownMigrationVersion $version

#echo $(getPreviousLocalMigrationVersion)
#incCurrentLocalMigrationVersion "$version"
#decCurrentLocalMigrationVersion
#resetMigrationProject
