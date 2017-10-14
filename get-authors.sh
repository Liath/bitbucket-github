#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR/hg

hgAuthors() {
  cd $1
  hg log --template "{author}\n" | sort -fu | xargs -d '\n' -n 1 -I '{}' echo "{}={}" > authors.map
  return 0
}
export -f hgAuthors

echo [hg] Collecting Authors
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'hgAuthors "$@"' _ {}

# Merge and cleanup dupes
AUTHOR_MAPS=$(find . -maxdepth 2 -name authors.map)
cat $AUTHOR_MAPS | sort -fu > $TMP_REPO_DIR/authors.map
rm $AUTHOR_MAPS

echo [hg] wrote \"$TMP_REPO_DIR/authors.map\". You should probably edit this to map authors to their names.
