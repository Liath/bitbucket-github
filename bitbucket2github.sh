#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo 'Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi

# Make a working directory
SELF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ $1 ]]; then
  if [ -d "$1" ]; then
    TMP_REPO_DIR=$1
  else
    echo "Given directory, \`$1\`, does not seem to exist."
  fi
else
  TMP_REPO_DIR=$(mktemp -d)
fi
echo Working directory is \"$TMP_REPO_DIR\"

# Get list of BitBucket repos
bash $SELF_DIR/get-bitbuckets.sh $TMP_REPO_DIR || exit 1
read -n1 -rsp $'If desired, you should now edit the git-repos and hg-repos files to select which repos you want to migrate.\nPress any key to continue...\n'

if [ -s "$TMP_REPO_DIR/hg-repos" ]; then
  # Fetch|update mercurial repos from BitBucket
  bash $SELF_DIR/clone-hg-repos.sh $TMP_REPO_DIR || exit 1

  # Collect authors from mercurial repos (used for mapping commits to users)
  bash $SELF_DIR/hg-get-authors.sh $TMP_REPO_DIR || exit 1
  read -n1 -rsp $'You should now edit the authors.map file to tell hg-fast-export which usernames are the same people.\nPress any key to continue...\n'

  # Collect branches from mercurial repos (used for fixing branch name issues)
  bash $SELF_DIR/hg-get-branches.sh $TMP_REPO_DIR || exit 1
  read -n1 -rsp $'I have made a best effort attempt at find branch names that will cause issues. You should edit branches.map now to make sure it looks acceptable or to add any other mappings.\nPress any key to continue...\n'

 # Export hg to git
 bash $SELF_DIR/hg2git.sh $TMP_REPO_DIR || exit 1
fi

if [ -s "$TMP_REPO_DIR/git-repos" ]; then
  # Fetch|update git repos from BitBucket
  bash $SELF_DIR/clone-git-repos.sh $TMP_REPO_DIR || exit 1
fi

# Push git repos to GitHub
bash $SELF_DIR/git2github.sh $TMP_REPO_DIR
