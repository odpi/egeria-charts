#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# Can be overriden by deployment - so script can be generic, but hardcode expected values for now
: "${GITREPO:=https://github.com/odpi/egeria-jupyter-notebooks}"
: "${GITBRANCH:=main}"
: "${LOCATION:=/home/jovyan/work}"

echo "-- Setting up Egeria notebooks --"

# Pause for debugging
if [ ! -z "$SCRIPT_SLEEP_BEFORE" ]; then
  echo "Sleeping for $SCRIPT_SLEEP_BEFORE seconds"
  sleep $SCRIPT_SLEEP_BEFORE
fi

# Shallow clone - just to get latest files, not history
if [ ! -r ${LOCATION}/.git ]
then
  echo "No git repo found in ${LOCATION}, cloning from ${GITREPO}..."
  cd ${LOCATION}/..
  # Cleanup lost and found and other directories - need to be empty for git
  rm -fr ${LOCATION}/*
  #git config --global --add safe.directory ${LOCATION}
  git clone --depth 1 ${GITREPO} ${LOCATION}
  cd ${LOCATION}
  git pull

  # Install additional packages if we've just pulled from git
  echo "-- Installing extra packages"
  conda install --yes --file ${LOCATION}/requirements.txt && \
       fix-permissions $CONDA_DIR && \
       fix-permissions /home/$NB_USER

  # We also checkout the requested tag if specified - but only during initial setup
  if [ ! -z ${GIT_TAG_NOTEBOOKS} ]
  then
    git fetch
    git checkout ${GIT_TAG_NOTEBOOKS}
  fi
else
  echo "Found git repo in ${LOCATION}, leaving as-is. update manually with 'git pull' or save work"

fi

# Pause for debugging
if [ ! -z "$SCRIPT_SLEEP_AFTER" ]; then
  echo "Sleeping for $SCRIPT_SLEEP_AFTER seconds"
  sleep $SCRIPT_SLEEP_AFTER
fi

echo "-- Egeria notebook setup complete --"


