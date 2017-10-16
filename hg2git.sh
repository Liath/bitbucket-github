#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo 'Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export FAST_EXPORT_PATH

TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR

mkgit() {
  mkdir -p $TMP_REPO_DIR/git/$1
  git init
  bash $FAST_EXPORT_PATH -r $TMP_REPO_DIR/hg/$1 -A $TMP_REPO_DIR/authors.map -f
  return 0
}
export -f mkgit

echo [hg] Exporting hg → git
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'mkgit "$@"' _ {}

echo [hg] Finished exporting
