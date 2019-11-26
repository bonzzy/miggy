#!/usr/bin/env bash

function incrementMinorVersion() {
  local __NEXT_VERSION=$(echo "$1" | awk -F. -v OFS=. '{print $1"."++$2"."$3}')
  echo $__NEXT_VERSION
}

function incrementMajorVersion() {
  local __NEXT_VERSION=$(echo "$1" | awk -F. -v OFS=. '{print ++$1"."$2"."$3}')
  echo $__NEXT_VERSION
}

function migrationVersionExist() {
    projectType=$1
    version=$2

  if [ -d "$PROJECT_PATH/$projectType/$version" ]; then
    echo true
  else
    echo false
  fi

}

function pullRepo() {
  echo "Updating repo... $PROJECT_PATH"

  if [ -d "$PROJECT_PATH/.git" ]; then
    cd "$PROJECT_PATH"
    git pull
    cd -
  else
    mkdir -p .cache_migrations
    cd $PROJECT_PATH
    ls -la
    git clone "$1" .
    cd -
  fi

}
