#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[clone-git] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export BB_ORG

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[clone-git] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR

mkdir -p git && cd git
gitClone() {
  echo [clone-git] Cloning $1
  if [ -d "$1" ]; then
    cd $1
    git fetch -q
  else
    git clone -q "ssh://$BB_ORG@bitbucket.org/$BB_ORG/$1"
  fi
  return 0
}
export -f gitClone

echo [clone-git] Fetch targets: $(<$TMP_REPO_DIR/git-repos xargs)
<$TMP_REPO_DIR/git-repos xargs -I '{}' -n 1 -P 32 bash -c 'gitClone "$@"' _ {}

for REPO_NAME in $(<$TMP_REPO_DIR/git-repos); do
  if [ ! -d $REPO_NAME ]; then
    echo [clone-git] Failed to fetch all target repos.
    exit 1
  fi
done
echo [clone-git] Done cloning
