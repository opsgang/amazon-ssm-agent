#!/bin/bash
#
# Builds the aws ssm agent, cli and document worker binaries
#
# Modifies src of agent bin so that ssm document worker bin's path
# is not hardcoded.
#
# At run-time you can tell the ssm-agent where the document-worker
# lives by setting the path to the binary in env var
# $SSM_DOCUMENT_WORKER_PATH
#
# Will default to /opt/ssm-agent/bin/ssm-document-worker
#
# #####################################################
# WHY THIS FORK?
# #####################################################
#
# The AWS system manager agent binary comes bundled with
# cli and document worker binaries.
#
# In CoreOS land the /usr filesystem is read-only so we can't
# install the document worker binary there.
# 
# Unfortunately the ssm-agent expects to find it in /usr/bin
#
# The SSM agent maintainers currently feel that hardcoding
# is preferred and have no plans to allow the user to configure
# the location of the document worker. 
#
# See https://github.com/aws/amazon-ssm-agent/issues/76
# and response at #issuecomment-348329917
#
# Hence this fork exists.
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
# #####################################################
# OPSGANG GITHUB RELEASES
# #####################################################
#
# Binary artefacts can be downloaded from the release tags.
#
. functions.coreos || exit 1
CURRENT_DIR=$(pwd)
modify_src "$CURRENT_DIR" || exit 1

make build-linux || exit 1

gather_release_artefacts || exit 1

# packaging ...

# On install, need to rewrite systemd service file based on arg passed by user:
# add line: Environment="SSM_DOCUMENT_WORKER_PATH=<USER_PATH>/ssm-document-worker"
# modify  : WorkingDirectory=<SSM_BIN_DIR>
# modify  : ExecStart=<SSM_BIN_DIR>/amazon-ssm-agent

