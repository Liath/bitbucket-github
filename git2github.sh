#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[git2GH] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export GH_ORG
export GH_CREDS

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[git2GH] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR/git

export GIT_REPOS=$(curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos" | jq 'map({name})')

gitPush() {
  FOUND=$(jq -r ".[] | select(.name|ascii_downcase==\"$1\") | .name" <<<$GIT_REPOS)
  if [[ $FOUND ]]; then
    echo [git2GH] Skipping $1 because it already exists on Github.
  else
    curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos" -d "{ \"name\": \"$1\", \"private\": true }"
    cd $TMP_REPO_DIR/git/$1
    git remote add origin "git@github.com:$GH_ORG/$1"
    git push --all
  fi
  return 0
}
export -f gitPush

cat $TMP_REPO_DIR/hg-repos $TMP_REPO_DIR/git-repos | xargs -I '{}' -n 1 -P 32 bash -c 'gitPush "$@"' _ {}

cd $TMP_REPO_DIR/git
for REPO_NAME in $(find . -maxdepth 1 ! -path . -type d -printf '%f\n'); do
  FOUND=$(jq -r ".[] | select(.name|ascii_downcase==\"$REPO_NAME\") | .name" <<<$GIT_REPOS)
  if [[ ! $FOUND ]]; then
    cd $TMP_REPO_DIR/git/$REPO_NAME
    if ! git ls-remote origin --exit-code; then
      echo [git2GH] Failed to push all target repos to GitHub.
      exit 1
    fi
  fi
done
echo [git2GH] Done pushing git repos to GitHub
