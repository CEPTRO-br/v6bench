#!/bin/sh

HOSTNAME="$(/usr/bin/hostname)"

if [ -f /shared/shared_data/scanapi_mode ]; then
    # shellcheck disable=SC1091
    . /shared/env/test_vars.env
    if [ -f /shared/env/credentials.env ]; then
        . /shared/env/credentials.env
    fi


    if timeout 60 sh -c "until nslookup ${BASE_DOMAIN} >/dev/null 2>&1; do sleep 1; done"; then
        echo "DNS server is up"
    else
        echo "Timed out waiting for DNS server" >&2
    fi

    URL_TEMPLATE="lab.${BASE_DOMAIN}"
    for sdom in ${SDOMS}; do

        if [ "${sdom}" = "siit" ]; then
            # waiting to SIIT to startup
            if [ "${BASE_PROTO}" = "https" ]; then
                TEST_PORT=443
            else
                TEST_PORT=80
            fi

            if timeout 60 sh -c "until nc -z 192.168.46.1 ${TEST_PORT}; do sleep 1; done"; then
                echo "SIIT server is up"
            else
                echo "Timed out waiting for SIIT server" >&2
            fi
        elif [ "${HOSTNAME}" = "ipv6_nat64_client" ] && [ "${sdom}" = "ipv4" ]; then
            # waiting to NAT64 to startup
            if timeout 60 sh -c 'until ping -c 1 -W 1 2001:db8:64::192.168.0.64 >/dev/null 2>&1; do sleep 1; done'; then
                echo "NAT64 server is up"
            else
                echo "Timed out waiting for NAT64 server" >&2
            fi
        fi

        export BASE_URL="${BASE_PROTO}://${sdom}.${URL_TEMPLATE}"
        OUTPUT_FILE="/shared/results/${HOSTNAME}-${sdom}-report.csv"

        PYTHONPATH=/shared/shared_data/notls scanapi run \
        -o "${OUTPUT_FILE}" \
        -t "/shared/shared_data/csv_template.jinja" \
        /shared/shared_data/scanapi.yaml > "/shared/results/logs/${HOSTNAME}-${sdom}.log" 2>&1

        sed -i "2,\$s/^/\"${HOSTNAME}\",/" "${OUTPUT_FILE}"
    done
elif [ -f /shared/shared_data/manual_mode ]; then
    sleep 30
    while pgrep -x bash > /dev/null; do
        sleep 1
    done
fi
