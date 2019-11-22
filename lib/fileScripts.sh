#!/usr/bin/env bash

createFile() {
  eval "touch $1"
}

deleteFile() {
  rm "$1"
}

fileExists() {
  if [[ -e $1 ]]; then
    echo 0
  else
    echo 1
  fi
}

setFileContent() {
  echo "$1" > "$2"
}

appendFileContent() {
  echo "$1" >> "$2"
}

checkIfFileHasString() {
  text=$1
  filePath=$2

#  0 true, 1 false
  cat ${filePath} | grep -qe ${text} ; echo $?
}

getFileContent() {
  CONTENT=$(cat "$1")
  echo "$CONTENT"
}
