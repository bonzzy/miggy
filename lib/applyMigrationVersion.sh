#!/usr/bin/env bash

applyUpMigrationVersion(){
  projectType=$1
  migrationVersion=$2
  MIGRATION_UP_SCRIPT="$PROJECT_PATH/$projectType/$migrationVersion/up.sh"

  if [[ "$migrationVersion" == "$(getCurrentLocalMigrationVersionForTemplateType ${projectType})" ]]; then
    return 1
  fi

  if [[ $(fileExists ${MIGRATION_UP_SCRIPT}) -eq 1 ]]; then
      return 1
  fi

  eval "/bin/bash $MIGRATION_UP_SCRIPT"

  if [[ ! $? ]]; then
    return 1
  fi

  incCurrentLocalMigrationVersion ${projectType} ${migrationVersion}
  return 0
}

applyDownMigrationVersion(){
  projectType=$1
  MIGRATION_DOWN_SCRIPT="$PROJECT_PATH/$projectType/$2/down.sh"

  if [[ $(fileExists $MIGRATION_DOWN_SCRIPT) -eq 1 ]]; then
      return 1
  fi

  eval "/bin/bash $MIGRATION_DOWN_SCRIPT" || /
  decCurrentLocalMigrationVersion ${projectType}

  return 0
}
