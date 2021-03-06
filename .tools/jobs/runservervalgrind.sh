#!/bin/bash

source ./.tools/scripts/init.sh

function run_server {
    echo "running: $1 --run-once $2"
    valgrind -q --read-var-info=yes --track-origins=yes --malloc-fill=11 --free-fill=55 --show-reachable=yes --leak-check=full --leak-resolution=high --partial-loads-ok=yes --error-limit=no $1 --run-once $2 2>runlog.txt
    export errcode=$?
    export teststr=$(grep "invalid" runlog.txt)
    cat runlog.txt
    if [[ -n "${teststr}" ]]; then
        echo "Errors found in running server $1."
        exit 1
    else
        echo "No errors found for server $1."
    fi
    if [ ${errcode} -ne 0 ]; then
        echo "server $1 terminated with exit code ${errcode}"
        echo "Test failed"
        exit 1
    fi
}

do_init_tools
init_configs $1

cd server-data
pwd
ls -la

run_server ./login-server
run_server ./char-server

ARGS="--load-script npc/dev/test.txt "
ARGS="--load-plugin script_mapquit $ARGS --load-script npc/dev/ci_test.txt"

run_server ./map-server "$ARGS"
