#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo '[get-githubs] Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export GH_ORG
export GH_CREDS

export TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "[get-githubs] A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi

rm -f "$TMP_REPO_DIR/github-repos-tmp.json"

echo [get-githubs] Spinning up...
PAGE_NUM=0
GIT_REPOS=""
while [ "$GIT_REPOS" != "[]" ];
do
  GIT_REPOS=$(curl -su $GH_CREDS "https://api.github.com/orgs/$GH_ORG/repos?page=$PAGE_NUM" | jq 'map({name})')
  echo $GIT_REPOS >> "$TMP_REPO_DIR/github-repos-tmp.json"
  let PAGE_NUM=PAGE_NUM+1
done

<"$TMP_REPO_DIR/github-repos-tmp.json" jq -s '. | flatten' > "$TMP_REPO_DIR/github-repos.json"
rm -f "$TMP_REPO_DIR/github-repos-tmp.json"

if [ ! -s "$TMP_REPO_DIR/github-repos.json" ]; then
  echo [get-githubs] Failed to retreive githubs, or there are none which is fine if that\'s the case
else
  echo [get-githubs] Done fetching list of repos on GitHub
fi
