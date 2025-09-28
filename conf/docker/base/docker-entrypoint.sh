#!/bin/sh

set -e

TARGET_SHELL=(fio/randread-4k.sh fio/randwrite-4k.sh fio/read-4k.sh fio/write-4k.sh)
if [ "$1" = "test" ]; then
    [ -d /var/log/fio ]
    for TEST_SHELL in ${TARGET_SHELL[@]}; do
        if [ -e ${TEST_SHELL} ]; then
            bash ${TEST_SHELL}
        else
            echo "${TEST_SHELL} not find."
        fi
    done
elif [ "$1" = "dev" ]; then
    bash
else
    exec "$@"
fi
