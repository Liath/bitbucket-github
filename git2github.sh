#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[git2GH] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export GH_ORG
export GH_CREDS

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[git2GH] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR/git

GIT_REPOS=$(curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos")

gitPush() {
  if [ $(<<<$GIT_REPOS | jq -r '.[] | select(.name=="$1") | .name') != $1 ]; then
    echo [git2GH] Skipping $1 because it already exists on Github.
  else
    curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos" -d '{"name": "$1", "private": true}'
    git remote set-url origin "git@github.com:$GH_ORG/$1"
    git push --all
  fi
  return 0
}
export -f gitPush

cat $TMP_REPO_DIR/hg-repos xargs $TMP_REPO_DIR/git-repos | xargs -I '{}' -n 1 -P 32 bash -c 'gitPush "$@"' _ {}

for REPO_NAME in find $TMP_REPO_DIR/git/ -maxdepth 1 ! -path . -type d; do
  cd $TMP_REPO_DIR/git/$REPO_NAME
  if ! git log ; then
    echo [git2GH] Failed to fetch all target repos.
    exit 1
  fi
done
echo [git2GH] Done pushing git repos to GitHub
