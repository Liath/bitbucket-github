#!/bin/bash
# Config
export BB_ORG='inviewlabs'
export BB_USER='Lupulus'
export BB_PASS=''
export GH_ORG='unifilabs'
export GH_CREDS='user:token' # Only repo permissions are needed, generate at https://github.com/settings/tokens
# End config

export BB_CREDS="$BB_USER:$BB_PASS"

# Make a working directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# TMP_REPO_DIR=$(mktemp -d)
TMP_REPO_DIR=/tmp/tmp.bOyNbabvDz
cd $TMP_REPO_DIR
echo Working directory is \"$TMP_REPO_DIR\"

# Get list of repos
# bash $SELF_DIR/get-bitbuckets.sh $TMP_REPO_DIR
cp /tmp/bb/git-repos .
cp /tmp/bb/hg-repos .

# Fetch|update repos
bash $SELF_DIR/clone-hg-repos.sh $TMP_REPO_DIR

# Collect Authors
bash $SELF_DIR/get-authors.sh $TMP_REPO_DIR

# Fixup author names
atom $TMP_REPO_DIR/authors.map

# Export hg to git
bash $SELF_DIR/hg2git.sh $TMP_REPO_DIR

# Fetch git repos from BitBucket
bash $SELF_DIR/clone-git-repos.sh $TMP_REPO_DIR

# Push git repos to GitHub
bash $SELF_DIR/git2github.sh $TMP_REPO_DIR
