##!/usr/bin/env bash
PROJECT_PATH="./.cache_migrations"

declare -a migrationFiles
FILE_PATH_HISTORY="$PROJECT_PATH/.history"
FILE_PATH_CURRENT="$PROJECT_PATH/.current"
FILE_PATH_CONFIG="$PROJECT_PATH/.config"
