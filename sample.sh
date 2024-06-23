#!/bin/bash
GIT_URL="https://github.com/tajuddin-sonata/salt-states.git"
GIT_BRANCH="main"

# List of Salt masters
SALT_MASTERS_ALL=(13.90.134.210 52.191.2.63)

echo ENVIRONMENT: $ENVIRONMENT
echo API_VERSION: $API_VERSION
echo REQUEST: $REQUEST
echo ARTIFACT_VERSION: $VERSION 
echo REGION: $REGION
echo HOSTS: $HOSTS
echo SALT_MASTERS: ${SALT_MASTERS_ALL[@]}

AGGR_HOSTS=()
hostnames=()
regions=()

if [[ ( $REGION == "east-us" ) ]]; then
  regions=$REGION
  SHORT_REG='eus'
elif [[ ( $REGION == "west-us" ) ]]; then
  regions=$REGION
  SHORT_REG='wus'
elif [[ ( $REGION == "all" ) ]]; then
  regions='*'
  SHORT_REG='*'
  MATCH_REG="all"
else
  echo "region is not defined"
  exit 1
fi

# This is the main deployment job
deployHosts() {
  salt_state="${1:-release-types.az.kafka-integration}"

  if [[ "${HOSTS[0]}" = "all" ]] && [[ "${HOSTS[@]}" =~ .*"kafka"[0-10].* ]]; then
    echo "Choice cannot contain selected both 'all' and 'hostname' at the same time"
    echo "Allowed choices either 'all' or 'multiple selected single hosts'"
    exit 1
  fi

  # Function to convert bash array to python comma delimited list
  function join { local IFS="$1"; shift; echo "$*"; }

  if [[ "$HOSTS" != "all" ]] && [[ ${HOSTS[@]} =~ .*"kafka"[0-10].* ]] && [[ $MATCH_REG == "all" ]]; then 
    for i in ${HOSTS[@]}; do
      for SALT_MASTER in "${SALT_MASTERS_ALL[@]}"; do
        echo "Processing host: $i using Salt-Master: ${SALT_MASTER}..."
        ssh root@${SALT_MASTER} "salt '${ENVIRONMENT}-${i}.az.${ENVIRONMENT}.${SHORT_REG}.cloud.net' state.apply $salt_state --state-output=full"
        echo "Deployed to host $i using Salt-Master: ${SALT_MASTER}"
      done
    done
  elif [[ "$HOSTS" != "all" ]] && [[ ${HOSTS[@]} =~ .*"kafka"[0-10].* ]]; then
    for i in ${HOSTS[@]}; do
      BUILD_HOSTS+=(${ENVIRONMENT}-${i}.az.${ENVIRONMENT}.${SHORT_REG}.cloud.net)
      AGGR_HOSTS=$(join , ${BUILD_HOSTS[@]})
      for SALT_MASTER in "${SALT_MASTERS_ALL[@]}"; do
        echo "Processing hosts: ${AGGR_HOSTS[@]} using Salt-Master: ${SALT_MASTER}..."
        ssh root@${SALT_MASTER} "salt -L '${AGGR_HOSTS[@]}' state.apply $salt_state --state-output=full"
        echo "Deployed to ${AGGR_HOSTS[@]} using Salt-Master: ${SALT_MASTER}"
      done
    done
  else
  echo "Deployed to $i"
  fi
}

# Call the deployHosts function
deployHosts
