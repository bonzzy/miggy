#!/usr/bin/env bash
PACKAGE_VERSION=1.8

up(){
    projectType=$1
    localVersion=$(getCurrentLocalMigrationVersionForTemplateType ${projectType})

    if [ -z $localVersion ]; then
        localVersion="1.0.0"

        else
          localVersion=$(incrementMinorVersion ${localVersion})
    fi

    logVerbose "Checking if a new version exists for '$projectType'"

    if [[ $(migrationVersionExist ${projectType} ${localVersion}) == false ]]; then
      logVerbose "[OK] All up to date!"
      version ${projectType}
      exit 0
    fi

    logVerbose "[UPDATE] Found a new version $localVersion"
    logVerbose "Running..."
    applyUpMigrationVersion ${projectType} "$localVersion"

    if [[ ! $? ]]; then
      logVerbose "[ERROR] There was a problem running the up.sh script for version $localVersion"
      logVerbose "Keeping the $(getCurrentLocalMigrationVersionForTemplateType ${projectType}) version"
      exit 1
    fi

    up ${projectType}
}

down() {
  projectType=$1
  if [[ -z $(getCurrentLocalMigrationVersionForTemplateType ${projectType}) ]]; then
      logVerbose "No migration found. Try to run migrate up ${projectType}."
      exit 1
  fi

  logVerbose "Version before migration down: $(getCurrentLocalMigrationVersionForTemplateType ${projectType})"
  logVerbose "Running $(getCurrentLocalMigrationVersionForTemplateType ${projectType}) down.sh:"

  if ! applyDownMigrationVersion ${projectType} $(getCurrentLocalMigrationVersionForTemplateType ${projectType}); then
    logVerbose "[ERROR] Something went wrong!"
    exit 1
  fi

  version ${projectType}
}

version() {
  projectType=$1
  echo "Project: $projectType"
  echo "Local version: $(getCurrentLocalMigrationVersionForTemplateType ${projectType})"
}

packageVersion() {
  echo "Migration project version:"
  echo "$PACKAGE_VERSION"
}
