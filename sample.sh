#!/bin/bash
GIT_URL="https://github.com/tajuddin-sonata/salt-states.git"
GIT_BRANCH="main"

# Note: Randomly pick a salt master from the list
SALT_MASTERS_ALL=(13.90.134.210 52.191.2.63)

# Get a random index for selecting a salt master
INDEX=$(($RANDOM % ${#SALT_MASTERS_ALL[@]}))

echo "ENVIRONMENT: $ENVIRONMENT"
echo "VERSION: $VERSION"
echo STACK: $STACK
echo "REGION: $REGION"
echo "HOSTS: $HOSTS"
echo "SALT_MASTER: ${SALT_MASTERS_ALL[$INDEX]}"

AGGR_HOSTS=()
hostnames=()
regions=()

if [[ $REGION == "east-us" ]]; then
    regions=$REGION
    SHORT_REG='eus'
elif [[ $REGION == "west-us" ]]; then
    regions=$REGION
    SHORT_REG='wus'
elif [[ $REGION == "all" ]]; then
    regions='*'
    SHORT_REG='*'
    MATCH_REG="all"
else
    echo "region is not defined"
fi

# This is a main deployment job
deployHosts() {
    salt_state="${1:-release-types.az.kafka-integration}"

    if [[ "${HOSTS[0]}" = "all" ]] && [[ "${HOSTS[@]}" =~ .*"kafka"[0-10].* ]]; then
        echo "Choice cannot contain selected both 'all' and 'hostname' at the same time"
        echo "Allowed choices either 'all' or ' multiple selected single hosts'"
        exit 1
    fi

    # Function to convert bash array to python comma delimited list
    function join { local IFS="$1"; shift; echo "$*"; }

    # NOTE: When selecting one host you will see full log from Saltstate output. When deploying to 'all' we suppress log output.
    if [[ "$HOSTS" != "all" ]] && [[ ${HOSTS[@]} =~ .*"web"[0-10].* ]] && [[ $MATCH_REG == "all" ]]; then 
        for i in ${HOSTS[@]}; do
            for salt_master in "${SALT_MASTERS_ALL[@]}"; do
                echo "Processing hosts:  $i using Salt-Master: $salt_master..."
                ssh root@$salt_master "salt '${ENVIRONMENT}-${i}.cca.${ENVIRONMENT}.${SHORT_REG}.cloud.247-inc.net' state.apply $salt_state --state-output=full"
                echo "Deployed to host $i"
            done
        done
    elif [[ "$HOSTS" != "all" ]] && [[ ${HOSTS[@]} =~ .*"web"[0-10].* ]]; then
        for i in ${HOSTS[@]}; do
            BUILD_HOSTS+=(${ENVIRONMENT}-${i}.cca.${ENVIRONMENT}.${SHORT_REG}.cloud.247-inc.net)
            AGGR_HOSTS=$(join , ${BUILD_HOSTS[@]})
            for salt_master in "${SALT_MASTERS_ALL[@]}"; do
                echo "Processing hosts:  ${AGGR_HOSTS[@]} using Salt-Master: $salt_master..."
                ssh root@$salt_master "salt -L '${AGGR_HOSTS[@]}' state.apply $salt_state --state-output=full"
                echo "Deployed to ${AGGR_HOSTS[@]}"
            done
        done
    else
        echo "Deployed to $i"
    fi
}

# Call the deployHosts function
deployHosts
