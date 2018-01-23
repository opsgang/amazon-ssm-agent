#!/bin/bash
#
# Builds the aws ssm agent, cli and document worker binaries
#
# Modifies src of agent bin so that ssm document worker bin's path
# can be user-defined at run-time.
#
# #####################################################
# OK, BUT THEN WHY THIS SCRIPT?
# #####################################################
#
# All fragile hackery required to get around should be in this
# pre-processer script.
#
# Yes, I could have just amended the src to allow configuration.
#
# But then when the forked-from repo is changed, it's harder
# to avoid merge conflicts.
#
# I just need the SSM agent to work on CoreOS ...
#
# By putting all changes in to this additional script, keeping in sync
# with the official source git repo is simpler.
#
. functions.coreos || exit 1
CURRENT_DIR=$(pwd)
modify_src "$CURRENT_DIR" || exit 1

make build-linux || exit 1
