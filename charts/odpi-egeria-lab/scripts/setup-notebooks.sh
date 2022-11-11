#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# Can be overriden by deployment - so script can be generic, but hardcode expected values for now
: "${GITREPO:=https://github.com/odpi/egeria-jupyter-notebooks}"
: "${GITBRANCH:=main}"
: "${LOCATION:=/home/jovyan/work}"
: "${STATUS:=/home/jovyan/work/.setupComplete}"

echo "-- Setting up Egeria notebook environment --"

# Pause for debugging
if [ -n "$SCRIPT_SLEEP_BEFORE" ]; then
  echo "-- Sleeping for $SCRIPT_SLEEP_BEFORE seconds"
  sleep "$SCRIPT_SLEEP_BEFORE"
fi

# First reset permissions (every time)
# Ensure that assigned uid has entry in /etc/passwd.
echo "-- Fixing user setup"

if [ "$(id -u)" -ge 10000 ]; then
 cat /etc/passwd | sed -e "s/^$NB_USER:/builder:/" > /tmp/passwd
 echo "$NB_USER:x:$(id -u):$(id -g):,,,:/home/$NB_USER:/bin/bash" >> /tmp/passwd
 cat /tmp/passwd > /etc/passwd
 rm /tmp/passwd
 fi

# Disable file permission warnings - we're running in a container, and the
# volume may not have our permissions
git config --global --add safe.directory '*'

# Only do this setup once ...

if [ ! -r "$STATUS" ]
then

  # Cleanup any partial setup
  echo "-- Cleaning up from any prior partial setup"
  rm -fr "${LOCATION}/lost+found"
  rm -fr "${LOCATION}/.git"

  # Shallow clone - just to get latest files, not history

  echo "-- Cloning from ${GITREPO} into ${LOCATION} ..."
  cd ${LOCATION}/.. || return
  git clone --depth 1 "${GITREPO}" "${LOCATION}"
  cd "${LOCATION}" || return
  git pull
  # We also checkout the requested tag if specified - but only during initial setup
  echo "-- Switching to requested git tag "
  if [ -n "${GIT_TAG_NOTEBOOKS}" ]
  then
    git fetch
    git checkout "${GIT_TAG_NOTEBOOKS}"
  fi
  # Mark as done (this is only for the content written to our persistent volume, ie git contents)
  mkdir -p touch "$STATUS"
fi

# Install additional packages if we've just pulled from git
echo "-- Installing extra conda packages"
conda install --yes --file "${LOCATION}/requirements.txt"

# Pause for debugging
if [ -n "$SCRIPT_SLEEP_AFTER" ]; then
  echo "-- Sleeping for $SCRIPT_SLEEP_AFTER seconds"
  sleep "$SCRIPT_SLEEP_AFTER"
fi

echo "-- Egeria notebook setup complete --"

return 0


