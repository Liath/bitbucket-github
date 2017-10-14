#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR

mkdir -p hg && cd hg
hgClone() {
  echo [hg] Cloning $1
  if [ -d "$1" ]; then
    cd $1
    hg pull -q --update
  else
    hg clone -q ssh://hg@bitbucket.org/$BB_ORG/$1
  fi
  return 0
}
export -f hgClone

echo [hg] Fetch targets: $(<$TMP_REPO_DIR/hg-repos xargs)
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'hgClone "$@"' _ {}

echo [hg] Done cloning
