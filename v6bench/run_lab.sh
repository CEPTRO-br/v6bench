#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
KATHARA_PATH="${SCRIPT_PATH}/kathara/"

# checking if lab still exists and cleans if needed
if ! (kathara linfo -d "${KATHARA_PATH}" |grep -Fq "No Devices Found"); then
    kathara lclean -d "${KATHARA_PATH}"
fi

echo "Starting Tests"
sudo kathara lstart --noterminals -d "${KATHARA_PATH}"

echo "Holding until execution finishes"
(kathara exec -d "${KATHARA_PATH}" gateway sleep infinity) >/dev/null 2>&1

echo "Tests are now completed. Cleaning environment"
kathara lclean -d "${KATHARA_PATH}"
echo "Done"
