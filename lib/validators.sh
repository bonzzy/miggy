#!/usr/bin/env bash

validateInitialization(){
  if [[ $(fileExists "${FILE_PATH_CURRENT}") -eq 1 ]]; then
    logVerbose "Your project has not been initialized yet."
    echo "Run initialization? [Y/y]"
    read answer

    if [[ "$answer" == "Y" ]] || [[ "$answer" == "y" ]]; then
        logVerbose "Initializing..."
        initMigrationProject

        logVerbose "[SUCCESS] Migration script project initialized."
        return
    fi

    logVerbose "Ok! Bye!"

    exit 1
  fi

  logVerbose "Project initialized already. Skipping..."
}
