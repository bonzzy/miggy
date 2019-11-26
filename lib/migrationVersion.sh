#!/usr/bin/env bash

PROJECT_PATH="./.cache_migrations"
PROJECT="maven"

currentLocalMigrationVersion() {
  getCurrentVersionForTemplateType ${PROJECT}
}

getCurrentLocalMigrationVersionForTemplateType() {
  getCurrentVersionForTemplateType $1
}

pushLocalMigrationVersionToHistory() {
  projectType=$1
  projectVersion=$2
  initIfHistoryEmptyForTemplateType "${projectType}"
  updatedFileContent=$(sed -e '/'"$projectType":'/a\'$'\n'' \ \ \ \- '$projectVersion ${FILE_PATH_HISTORY})
  setFileContent "${updatedFileContent}" "${FILE_PATH_HISTORY}"
}

popLocalMigrationVersionFromHistory() {
  projectType=$1
  projectVersion=$2

  if [[ -z $(getCurrentLocalMigrationVersionForTemplateType ${projectType}) ]]; then
    if [[ -z ${projectVersion} ]]; then
    return 0
    fi
  fi

  sedCommand="/$projectType/{n;d;}"
  sed -i.bak -e "$sedCommand" "${FILE_PATH_HISTORY}" && rm ${FILE_PATH_HISTORY}.bak
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
        sed -i.bak "s/$projectType: [0-9|.].*$/$projectType: $projectVersion/" ${FILE_PATH_CURRENT} && rm ${FILE_PATH_CURRENT}.bak
        return 0
    fi

    sed -i.bak "s/$projectType:.*$/$projectType: $projectVersion/" ${FILE_PATH_CURRENT} && rm ${FILE_PATH_CURRENT}.bak
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
  createFile ${FILE_PATH_CURRENT}
  createFile ${FILE_PATH_HISTORY}
  createFile ${FILE_PATH_CONFIG}

  appendFileContent "projects:" ${FILE_PATH_CURRENT}
  appendFileContent "projects:" ${FILE_PATH_HISTORY}

  setConfig "$templateUrl" "$templateType"
}

setConfig() {
  gitUrl=$1
  templateType=$2

  setFileContent "project:" ${FILE_PATH_CONFIG}
  appendFileContent "  git_url: $gitUrl" ${FILE_PATH_CONFIG}
  appendFileContent "  template_type: $templateType" ${FILE_PATH_CONFIG}
}

resetMigrationProject() {
  rm -rf $PROJECT_PATH
}
