#!/bin/bash
export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[hg-authors] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR/hg

hgAuthors() {
  cd $1
  hg log --template "{author}\n" | sed -r 's|"|\\"|g' | sort -fu | xargs -d '\n' -n 1 -I '{}' echo "\"{}\"=\"{}\"" > authors.map
  return 0
}
export -f hgAuthors

echo [hg-authors] Collecting Authors
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'hgAuthors "$@"' _ {}

# Merge and cleanup dupes
AUTHOR_MAPS=$(find . -maxdepth 2 -name authors.map)
echo '"<>"="<devnull@localhost>"' > $TMP_REPO_DIR/authors.map
echo '"\<\>"="<devnull@localhost>"' >> $TMP_REPO_DIR/authors.map
echo '"<devnull@localhost>"="<devnull@localhost>"' >> $TMP_REPO_DIR/authors.map
cat $AUTHOR_MAPS | sort -fu >> $TMP_REPO_DIR/authors.map
rm $AUTHOR_MAPS

if [ ! -f $TMP_REPO_DIR/authors.map ]; then
  echo '[hg-authors] Failed to generate authors map.'
  exit 1
fi
echo [hg-authors] wrote \"$TMP_REPO_DIR/authors.map\".
