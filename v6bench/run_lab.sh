#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
KATHARA_PATH="${SCRIPT_PATH}/kathara/"

# building docker image for clients if needed
if ! docker image inspect v6bench/client:latest > /dev/null 2>&1; then
	echo "Building docker image for v6bench client nodes"
	docker build -f "${SCRIPT_PATH}/v6bench_client.Dockerfile" -t v6bench/client:latest .
fi

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
echo "Results are available in ${KATHARA_PATH}shared/results/*.csv"
echo "Logs are available in ${KATHARA_PATH}shared/results/logs/*.log"
