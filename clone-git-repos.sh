#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR

mkdir -p git && cd git
gitClone() {
  echo [git] Cloning $1
  if [ -d "$1" ]; then
    cd $1
    git fetch -q
  else
    git clone -q "ssh://$BB_ORG@bitbucket.org/$BB_ORG/$1"
  fi
  return 0
}
export -f gitClone

echo [git] Fetch targets: $(<$TMP_REPO_DIR/git-repos xargs)
<$TMP_REPO_DIR/git-repos xargs -I '{}' -n 1 -P 32 bash -c 'gitClone "$@"' _ {}

echo [git] Done cloning
