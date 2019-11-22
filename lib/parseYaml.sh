#!/usr/bin/env bash

# Based on https://gist.github.com/pkuczynski/8665367

getProjectGitUrl() {
  readConfig
  echo $config_project_git_url
}

getProjectTemplateType() {
  readConfig
  echo $config_project_template_type
}

getCurrentVersionForTemplateType() {
  templateType=$1
  readCurrentVersionYaml
  yamlVariable="current_projects_$templateType"
  echo ${!yamlVariable}
}

getPreviousVersionForTemplateType() {
  templateType=$1
  readHistoryVersionYaml
  yamlVariable="history_projects_$templateType"[1]
  previousVersion=${!yamlVariable}

  echo ${previousVersion}
}

initIfHistoryEmptyForTemplateType() {
  templateType=$1
  typeExistsInCurrent=$(checkIfFileHasString ${templateType} ${migrationFiles[ALL]})

  if [[ ${typeExistsInCurrent} -eq 1 ]]; then
    appendFileContent "  $templateType:" ${migrationFiles[ALL]}
  fi
}

initIfCurrentVersionEmptyForTemplateType() {
  templateType=$1
  typeExistsInCurrent=$(checkIfFileHasString ${templateType} ${migrationFiles[LATEST]})

  if [[ ${typeExistsInCurrent} -eq 1 ]]; then
      appendFileContent "  $templateType:" ${migrationFiles[LATEST]}
  fi
}

readConfig() {
    local yaml_file="${migrationFiles[CONFIG]}"
    local prefix="config_"
    eval "$(parse_yaml "$yaml_file" "$prefix")"
    PROJECT=$config_project_template_type
}

readCurrentVersionYaml() {
    local yaml_file="${migrationFiles[LATEST]}"
    local prefix="current_"
    eval "$(parse_yaml "$yaml_file" "$prefix")"
}

readHistoryVersionYaml() {
    local yaml_file="${migrationFiles[ALL]}"
    local prefix="history_"
    eval $(parse_yaml "$yaml_file" "$prefix")
}

parse_yaml() {
    local yaml_file=$1
    local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |

        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
                }
            }' |

        sed -e 's/_=/+=/g' |

        awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) < "$yaml_file"
}
