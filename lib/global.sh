#!/usr/bin/env bash

declare -A configFiles
appVersion=0.0.1
configFiles[migrations]=".migrations"
configFiles[currentmigration]=".currentmigration"
configFiles[config]=".migrationsrc"

