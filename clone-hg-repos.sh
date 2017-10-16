#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo 'Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export BB_ORG

TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
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
