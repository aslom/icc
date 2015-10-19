#!/bin/bash
#debug
#set -x


ICC_VERSION_ARG=${ICC_VERSION:-v0.0.5}

ICC_ENV_ARG=${ICC_ENV:-default}

if [ "$1" = "help" ]; then
  echo "Commands: create-data-env delete-data-env"
  echo "Note: parameters from ${ICC_ENV_DIR}${ICC_ENV_ARG}_env.sh only added to commands: cf login, cf ic loging and ice login"
  exit 0
fi

source ${ICC_ENV_DIR}${ICC_ENV_ARG}_env.sh

if [ "$LOCAL" == "true" ]; then
  [ -n "$DOCKER_HOST" ] && IC_DOCKER_HOST_ARG="-e DOCKER_HOST=$DOCKER_HOST"
  [ -n "$DOCKER_CERT_PATH" ] && IC_DOCKER_CERT_PATH_ARG="-e DOCKER_CERT_PATH=$DOCKER_CERT_PATH"
  #[ -n "$IC_DOCKER_CERT_PATH" ] && IC_DOCKER_CERT_PATH_ARG="-e DOCKER_CERT_PATH=$IC_DOCKER_CERT_PATH"
  [ -n "$DOCKER_TLS_VERIFY" ] && IC_DOCKER_TLS_VERIFY_ARG="-e DOCKER_TLS_VERIFY=$DOCKER_TLS_VERIFY"
  LOCAL_DOCKER_DIR_MOUNT=""
  if [ "$DOCKER_TLS_VERIFY" = "1" ] && [ -n "$DOCKER_CERT_PATH" ] ; then
    #CERTS_DIR=$(dirname "${DOCKER_CERT_PATH}")
    #LOCAL_DOCKER_DIR_MOUNT="-v ${CERTS_DIR}:${CERTS_DIR}"
    LOCAL_DOCKER_DIR_MOUNT="-v ${DOCKER_CERT_PATH}:${DOCKER_CERT_PATH}:ro"
  fi
  if [ -e /var/run/docker.sock ] ; then
    LOCAL_DOCKER_DIR_MOUNT="-v /var/run/docker.sock:/var/run/docker.sock"
  fi
  #LOCAL_DOCKER_DIR_MOUNT="-v $HOME/.docker:$HOME/.docker"
  #LOCAL_DOCKER_DIR_MOUNT="-v $HOME/.docker/machine:$HOME/.docker/machine"
else
  [ -n "$IC_DOCKER_HOST" ] && IC_DOCKER_HOST_ARG="-e DOCKER_HOST=$IC_DOCKER_HOST"
  [ -n "$IC_DOCKER_CERT_PATH" ] && IC_DOCKER_CERT_PATH_ARG="-e DOCKER_CERT_PATH=$IC_DOCKER_CERT_PATH"
  [ -n "$IC_DOCKER_TLS_VERIFY" ] && IC_DOCKER_TLS_VERIFY_ARG="-e DOCKER_TLS_VERIFY=$IC_DOCKER_TLS_VERIFY"
  LOCAL_DOCKER_DIR_MOUNT=""
fi

ENV_ARGS="$IC_DOCKER_HOST_ARG $IC_DOCKER_CERT_PATH_ARG $IC_DOCKER_TLS_VERIFY_ARG"

if [ "$1" = "check" ]; then
  docker -v
  exit 0
fi

if [ "$1" = "create-data-env" ]; then
  docker create -v /home/icsng --name icc_env_${ICC_ENV_ARG} aslom/icc:${ICC_VERSION_ARG} /bin/bash
  exit 0
elif [ "$1" = "delete-data-env" ] ; then
  docker rm -f icc_env_${ICC_ENV_ARG}
  exit 0
elif [ "$1" = "check-data-env" ] ; then
  docker run -it --volumes-from icc_env_${ICC_ENV_ARG} ubuntu /bin/bash
  exit 0
fi



ACTION=""
#echo ZERO=$0
if [ "$0" = "cf.sh" ] || [ "$0" = "./cf" ] ; then
  ACTION="cf"
elif [ "$0" = "ic.sh" ] || [ "$0" = "./ic" ] ; then
  ACTION="ic"
elif [ "$0" = "ice.sh" ] || [ "$0" = "./ice" ] ; then
  ACTION="ice"
elif [ "$0" = "docker.sh" ] || [ "$0" = "./docker" ] ; then
  ACTION="docker"
fi
#echo ACTION=$ACTION

# TODO shift args into PRE_ARGS

ARGS=""
if [ "$1" = "cf" ]; then
  if [ "$2" = "login" ]; then
    [ -n "$CF_API_HOST" ] && CF_API_ARG="-a $CF_API_HOST"
    [ -n "$IBM_ID_USER" ] && IBM_ID_USER_ARG="-u $IBM_ID_USER"
    [ -n "$IBM_ID_PASS" ] && IBM_ID_PASS_ARG="-p $IBM_ID_PASS"
    [ -n "$BLUEMIX_ORG" ] && BLUEMIX_ORG_ARG="-o $BLUEMIX_ORG"
    [ -n "$BLUEMIX_SPACE" ] && BLUEMIX_SPACE_ARG="-s $BLUEMIX_SPACE"
    ARGS="$CF_API_ARG $BLUEMIX_ORG_ARG $BLUEMIX_SPACE_ARG $IBM_ID_USER_ARG $IBM_ID_PASS_ARG"
    ARGS_CLEAN="${ARGS//$IBM_ID_PASS/SECRET}"
    echo running $* $ARGS_CLEAN
  elif [ "$2" = "ic" ]; then
    if [ "$3" = "login" ]; then
      #[ -n "$CF_API_HOST" ] && CF_API_ARG="-a https://$CF_API_HOST"
      [ -n "$IC_HOST" ] && IC_HOST_ARG="--host $IC_HOST"
      #[ -n "$IC_REGISTRY" ] && IC_REGISTRY_ARG="-R $IC_REGISTRY"
      ARGS="$CF_API_ARG $IC_HOST_ARG $IC_REGISTRY_ARG"
      echo running $* $ARGS
    fi
  fi
#elif [ "$1" = "ic" ]; then
#  PRE_ARGS="cf"
#  if [ "$2" = "login" ]; then
#    [ -n "$CF_API_HOST" ] && CF_API_ARG="-a https://$CF_API_HOST"
#    [ -n "$IC_HOST" ] && IC_HOST_ARG="-H $IC_HOST"
#    [ -n "$IC_REGISTRY" ] && IC_REGISTRY_ARG="-R $IC_REGISTRY"
#    ARGS="$CF_API_ARG $IC_HOST_ARG $IC_REGISTRY_ARG"
#    echo running $* $ARGS
#  fi
elif [ "$1" = "ice" ]; then
  if [ "$2" = "login" ]; then
    [ -n "$CF_API_HOST" ] && CF_API_ARG="-a https://$CF_API_HOST"
    [ -n "$IBM_ID_USER" ] && IBM_ID_USER_ARG="-u $IBM_ID_USER"
    [ -n "$IBM_ID_PASS" ] && IBM_ID_PASS_ARG="-p $IBM_ID_PASS"
    [ -n "$BLUEMIX_ORG" ] && BLUEMIX_ORG_ARG="-o $BLUEMIX_ORG"
    [ -n "$BLUEMIX_SPACE" ] && BLUEMIX_SPACE_ARG="-s $BLUEMIX_SPACE"
    [ -n "$IC_HOST" ] && IC_HOST_ARG="-H $IC_HOST"
    [ -n "$IC_REGISTRY" ] && IC_REGISTRY_ARG="-R $IC_REGISTRY"
    ARGS="$CF_API_ARG $BLUEMIX_ORG_ARG $BLUEMIX_SPACE_ARG $IC_HOST_ARG $IC_REGISTRY_ARG $IBM_ID_USER_ARG $IBM_ID_PASS_ARG"
    ARGS_CLEAN="${ARGS//$IBM_ID_PASS/SECRET}"
    echo running $* $ARGS_CLEAN
  fi
fi

#CMD="docker run -it --rm -v $HOME:/root -v $PWD:/opt/workdir icsng/client $@"
#docker run -it --env-file env_${CLIENT_ENV_ARG}.sh --volumes-from icsng_env_${CLIENT_ENV_ARG} -v $PWD:/opt/workdir --rm icsng/client $*
docker run -it --volumes-from icc_env_${ICC_ENV_ARG} -v $PWD:/opt/workdir $LOCAL_DOCKER_DIR_MOUNT $ENV_ARGS --rm aslom/icc:${ICC_VERSION_ARG} $PRE_ARGS $* $ARGS
#echo CMD=$CMD
#$CMD
