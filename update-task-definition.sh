#!/bin/bash

set -e

TAG=$1
TASK_DEFINITION_FILE=$2
UPDATED_TASK_DEFINITION_FILE=$3

if [ -z "$TAG" ] || [ -z "$TASK_DEFINITION_FILE" ] || [ -z "$UPDATED_TASK_DEFINITION_FILE" ]; then
    echo "Usage: ./update-task-definition.sh <tag> <task-definition-file> <updated-task-definition-file>"
    exit 1
fi

sed "s/\${TAG}/$TAG/g" $TASK_DEFINITION_FILE > $UPDATED_TASK_DEFINITION_FILE
