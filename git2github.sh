#!/bin/bash
TMP_REPO_DIR=$1
cd $TMP_REPO_DIR/git

GIT_REPOS=$(curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos")

gitPush() {
  if [ $(<<<$GIT_REPOS | jq -r '.[] | select(.name=="$1") | .name') != $1 ]; then
    echo Skipping $1 because it already exists on Github.
  else
    curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos" -d '{"name": "$1", "private": true}'
    git remote set-url origin "git@github.com:$GH_ORG/$1"
    git push --all
  fi
  return 0
}
export -f gitPush

<$TMP_REPO_DIR/git-repos xargs -I '{}' -n 1 -P 32 bash -c 'gitPush "$@"' _ {}

echo [git] Done pushing git repos to GitHub
