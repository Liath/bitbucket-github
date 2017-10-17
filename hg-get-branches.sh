#!/bin/bash
export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[hg-branches] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR/hg

hgBranches() {
  cd $1
  hg log --template "{branch}\n" | sort -fu > branches.map
  return 0
}
export -f hgBranches

echo [hg-branches] Collecting branches
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'hgBranches "$@"' _ {}

# Merge and cleanup dupes
BRANCH_MAPS=$(find . -maxdepth 2 -name branches.map)
BRANCHES=$(cat $BRANCH_MAPS | sort -fu)
rm $BRANCH_MAPS
for BASE_BRANCH in $BRANCHES; do
  for OTHER_BRANCH in $BRANCHES; do
    if [[ $OTHER_BRANCH == $BASE_BRANCH/* ]]; then
      echo "\"$OTHER_BRANCH\"=\"$(sed -r 's|/|-|g' <<<$OTHER_BRANCH)\"" >> $TMP_REPO_DIR/branches.map
    fi
  done
done

echo [hg-branches] wrote \"$TMP_REPO_DIR/branches.map\".
