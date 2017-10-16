#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo 'Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi

# Make a working directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_REPO_DIR=$(mktemp -d)
cd $TMP_REPO_DIR
echo Working directory is \"$TMP_REPO_DIR\"

# Get list of BitBucket repos
bash $SELF_DIR/get-bitbuckets.sh $TMP_REPO_DIR

# Fetch|update mercurial repos from BitBucket
bash $SELF_DIR/clone-hg-repos.sh $TMP_REPO_DIR

# Collect Authors from mercurial repos (used for mapping commits to users)
bash $SELF_DIR/hg-get-authors.sh $TMP_REPO_DIR

# Fixup author names
atom $TMP_REPO_DIR/authors.map

# Export hg to git
bash $SELF_DIR/hg2git.sh $TMP_REPO_DIR

# Fetch|update git repos from BitBucket
bash $SELF_DIR/clone-git-repos.sh $TMP_REPO_DIR

# Push git repos to GitHub
bash $SELF_DIR/git2github.sh $TMP_REPO_DIR
