#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[hg2git] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export FAST_EXPORT_PATH

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[hg2git] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR

mkgit() {
  mkdir -p $TMP_REPO_DIR/git/$1
  cd $TMP_REPO_DIR/git/$1
  git init
  bash $FAST_EXPORT_PATH -r $TMP_REPO_DIR/hg/$1 -A $TMP_REPO_DIR/authors.map -f
  return 0
}
export -f mkgit

echo [hg2git] Exporting hg → git in $TMP_REPO_DIR
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'mkgit "$@"' _ {}

for REPO_NAME in $TMP_REPO_DIR/hg-repos; do
  cd $TMP_REPO_DIR/git/$REPO_NAME
  if ! git ls-remote faraway --exit-code ; then
    echo [hg2git] Failed to push all target repos to GitHub.
    exit 1
  fi
done
echo [hg2git] Finished exporting
