#!/bin/sh

# Validate execution mode
MODE="$1"

if [ -z "${MODE}" ]; then
    echo "Error: Run mode not specified."
    echo "Usage: $0 {MANUAL|SCANAPI}"
    exit 1
fi

case "${MODE}" in
    MANUAL|SCANAPI)
        ;;
    *)
        echo "Error: Invalid run mode '${MODE}'."
        echo "Usage: $0 {MANUAL|SCANAPI}"
        exit 1
        ;;
esac

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
KATHARA_PATH="${SCRIPT_PATH}/kathara/"

# building docker image for clients if needed
if ! docker image inspect v6bench/client:latest > /dev/null 2>&1; then
	echo "Building docker image for v6bench client nodes"
	docker build -f "${SCRIPT_PATH}/v6bench_client.Dockerfile" -t v6bench/client:latest .
fi

# building docker image for clients if needed
if ! docker image inspect v6bench/translator:latest > /dev/null 2>&1; then
	echo "Building docker image for v6bench NAT64 and SIIT-DC nodes"
	docker build -f "${SCRIPT_PATH}/v6bench_translator.Dockerfile" -t v6bench/translator:latest .
fi

# checking if lab still exists and cleans if needed
if ! (kathara linfo -d "${KATHARA_PATH}" |grep -Fq "No Devices Found"); then
    kathara lclean -d "${KATHARA_PATH}"
fi

# [TODO] add condition to run in either manual or automatic mode

if [ "${MODE}" = "SCANAPI" ]; then
	echo "Starting Tests in ScanAPI mode"
	touch "${KATHARA_PATH}shared/shared_data/scanapi_mode"
	sudo kathara lstart --noterminals -d "${KATHARA_PATH}"
	rm -f "${KATHARA_PATH}shared/shared_data/scanapi_mode"
elif [ "${MODE}" = "MANUAL" ]; then
	echo "Starting environment in manual mode"
	touch "${KATHARA_PATH}shared/shared_data/manual_mode"
	sudo kathara lstart -d "${KATHARA_PATH}"
	rm -f "${KATHARA_PATH}shared/shared_data/manual_mode"
else
	exit
fi

echo "Holding until execution finishes"
(kathara exec -d "${KATHARA_PATH}" gateway sleep infinity) >/dev/null 2>&1

echo "Tests are now completed. Cleaning environment"
kathara lclean -d "${KATHARA_PATH}"
echo "Done"

if [ "${MODE}" = "SCANAPI" ]; then
	echo "Results are available in ${KATHARA_PATH}shared/results/*.csv"
	echo "Logs are available in ${KATHARA_PATH}shared/results/logs/*.log"
fi