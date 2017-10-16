#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR

mkgit() {
  mkdir -p $TMP_REPO_DIR/git/$1
  git init
  ~/Repos/fast-export/hg-fast-export.sh -r $TMP_REPO_DIR/hg/$1 -A $TMP_REPO_DIR/authors.map -f
  return 0
}
export -f mkgit

echo [hg] Exporting hg → git
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'mkgit "$@"' _ {}

echo [hg] Finished exporting
