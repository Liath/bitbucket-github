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
read -rsp $"If desired, you should now edit the \`git-repos\` and \`hg-repos\` files in \`$TMP_REPO_DIR\` to select which repos you want to migrate.\nPress enter to continue...\n"

# Fetch list of existing repos so we can skip any that will just throw an error because they exist
# If you are rerunning this script because of error, you can remove anything listed in github-repos.json to get it be retried.
bash $SELF_DIR/get-githubs.sh $TMP_REPO_DIR || exit 1

if [ -s "$TMP_REPO_DIR/hg-repos" ]; then
  # Fetch|update mercurial repos from BitBucket
  bash $SELF_DIR/clone-hg-repos.sh $TMP_REPO_DIR || exit 1

  # Collect authors from mercurial repos (used for mapping commits to users)
  bash $SELF_DIR/hg-get-authors.sh $TMP_REPO_DIR || exit 1
  read -rsp $"You should now edit \`$TMP_REPO_DIR/authors.map\` to tell hg-fast-export which usernames are the same people.\nPress enter to continue...\n"

  # Collect branches from mercurial repos (used for fixing branch name issues)
  bash $SELF_DIR/hg-get-branches.sh $TMP_REPO_DIR || exit 1
  read -rsp $"You may now create/edit \`$TMP_REPO_DIR/branches.map\` to add any needed mappings.\nPress enter to continue...\n"

 # Export hg to git
 bash $SELF_DIR/hg2git.sh $TMP_REPO_DIR || exit 1
fi

if [ -s "$TMP_REPO_DIR/git-repos" ]; then
  # Fetch|update git repos from BitBucket
  bash $SELF_DIR/clone-git-repos.sh $TMP_REPO_DIR || exit 1
fi

# Push git repos to GitHub
bash $SELF_DIR/git2github.sh $TMP_REPO_DIR
