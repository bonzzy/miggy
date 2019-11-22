#!/usr/bin/env bash

PROJECT_PATH="./.cache_migrations"
PROJECT="maven"

declare -A migrationFiles
migrationFiles[ALL]="$PROJECT_PATH/.history"
migrationFiles[LATEST]="$PROJECT_PATH/.current"
migrationFiles[CONFIG]="$PROJECT_PATH/.migration.config"

export MIGRATION_LATEST_PATH=${migrationFiles[LATEST]}
export MIGRATION_CONFIG_PATH=${migrationFiles[CONFIG]}
export MIGRATION_ALL_PATH=${migrationFiles[ALL]}

currentLocalMigrationVersion() {
  getCurrentVersionForTemplateType ${PROJECT}
}

getCurrentLocalMigrationVersionForTemplateType() {
  getCurrentVersionForTemplateType $1
}

pushLocalMigrationVersionToHistory() {
  projectType=$1
  projectVersion=$2
  initIfHistoryEmptyForTemplateType ${projectType}
  sed  -i -e "/\ $projectType:/a \ \ \ \ - $projectVersion" ${migrationFiles[ALL]}
}

popLocalMigrationVersionFromHistory() {
  projectType=$1
  projectVersion=$2

  if [[ -z $(getCurrentLocalMigrationVersionForTemplateType ${projectType}) ]]; then
    if [[ -z ${projectVersion} ]]; then
    return 0
    fi
  fi

  sedCommand="/$projectType/{n;d}"
  sed -i -e "$sedCommand" ${migrationFiles[ALL]}
}

decCurrentLocalMigrationVersion() {
  projectType=$1
  currentVersion=$(currentLocalMigrationVersion)
  setCurrentLocalMigrationVersion ${projectType} $(getPreviousLocalMigrationVersion ${projectType})
  popLocalMigrationVersionFromHistory ${projectType} ${currentVersion}
}

incCurrentLocalMigrationVersion() {
  projectType=$1
  version=$2
  setCurrentLocalMigrationVersion ${projectType} "$version"
  pushLocalMigrationVersionToHistory ${projectType} "$version"
}

setCurrentLocalMigrationVersion() {
    projectVersion=$2
    projectType=$1

    currentVersion=$(getCurrentLocalMigrationVersionForTemplateType $projectType)
    initIfCurrentVersionEmptyForTemplateType ${projectType}

    if [[ ! -z ${currentVersion} ]]; then
        sed -ri "s/$projectType: [0-9|.].*$/$projectType: $projectVersion/" ${migrationFiles[LATEST]}
        return 0
    fi

    sed -ri "s/$projectType:.*$/$projectType: $projectVersion/" ${migrationFiles[LATEST]}
}

getPreviousLocalMigrationVersion() {
   templateType=$1
   echo $(getPreviousVersionForTemplateType ${templateType})
}

initMigrationProject() {
  echo Enter the migration type for templates?
  read templateType

  MIGRATION_TYPE=templateType
  logVerbose "Template type set to $templateType"

  echo Enter your git url for templates?
  read templateUrl

  logVerbose "Pulling repo: $templateUrl"
  mkdir $PROJECT_PATH
  pullRepo "$templateUrl"

  logVerbose "Creating $PROJECT_PATH config files..."
  createFile ${migrationFiles[LATEST]}
  createFile ${migrationFiles[ALL]}
  createFile ${migrationFiles[CONFIG]}

  appendFileContent "projects:" ${migrationFiles[LATEST]}
  appendFileContent "projects:" ${migrationFiles[ALL]}

  setConfig "$templateUrl" "$templateType"
}

setConfig() {
  gitUrl=$1
  templateType=$2

  setFileContent "project:" ${migrationFiles[CONFIG]}
  appendFileContent "  git_url: $gitUrl" ${migrationFiles[CONFIG]}
  appendFileContent "  template_type: $templateType" ${migrationFiles[CONFIG]}
}

resetMigrationProject() {
  rm -rf $PROJECT_PATH
}
