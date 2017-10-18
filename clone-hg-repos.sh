#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[clone-hg] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export BB_ORG

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[clone-hg] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR

mkdir -p hg
cd hg
hgClone() {
  echo [clone-hg] Cloning $1
  if [ -d "$1" ]; then
    cd $1
    hg pull -q --update
  else
    hg clone -q ssh://hg@bitbucket.org/$BB_ORG/$1
  fi
  return 0
}
export -f hgClone

echo [clone-hg] Fetch targets: $(<$TMP_REPO_DIR/hg-repos xargs)
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'hgClone "$@"' _ {}

for REPO_NAME in $(<$TMP_REPO_DIR/hg-repos); do
  if [ ! -d $REPO_NAME ]; then
    echo [clone-hg] Failed to fetch all target repos.
    exit 1
  fi
done
echo [clone-hg] Done cloning
