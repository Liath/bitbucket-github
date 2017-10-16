#!/bin/bash
# Config
if [ ! -f config.sh ]; then
  echo 'Please update `config.sh.example` and save it as `config.sh`.'
  exit 1
fi
source config.sh
export BB_ORG
export BB_CREDS

TMP_REPO_DIR=$1
if [ ! -d "$TMP_REPO_DIR" ]; then
  echo "A working directory is required. Use something like \`./$0 /tmp/dir\`."
  exit 1
fi
cd $TMP_REPO_DIR

# Get list of repos
echo Fetching listing of repos on BitBucket...
echo "https://api.bitbucket.org/2.0/repositories/$BB_ORG" > $TMP_REPO_DIR/url
while [ -s $TMP_REPO_DIR/url ]; do
  BB_RES=$(curl --user $BB_CREDS -s $(< $TMP_REPO_DIR/url))
  jq -r '[.values[] | select(.scm=="hg")][].slug' <<< $BB_RES >> $TMP_REPO_DIR/hg-repos
  jq -r '[.values[] | select(.scm=="git")][].slug' <<< $BB_RES >> $TMP_REPO_DIR/git-repos
  jq -r '.next' <<< $BB_RES > $TMP_REPO_DIR/url
done
rm $TMP_REPO_DIR/url

echo Repo lists written to \"$TMP_REPO_DIR\" as git-repos and hg-repos
