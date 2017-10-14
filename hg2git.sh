#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR

GIT_REPOS=$(curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos")

mkgit() {
  if [ $(<<<$GIT_REPOS | jq -r '.[] | select(.name=="$1") | .name') != $1 ]; then
    echo Skipping $1 because it already exists on Github.
  else
    mkdir -p $TMP_REPO_DIR/git/$1
    git init
    ~/Repos/fast-export/hg-fast-export.sh -r $TMP_REPO_DIR/hg/$1 -A $TMP_REPO_DIR/authors.map -f
    curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos" -d '{"name": "$1", "private": true}'
    git add remote origin git@github.com:$GH_ORG/$1
    git push --all
  fi
  return 0
}
export -f mkgit

echo [hg] Exporting hg → git
<$TMP_REPO_DIR/hg-repos xargs -I '{}' -n 1 -P 32 bash -c 'mkgit "$@"' _ {}

echo [hg] Finished exporting
