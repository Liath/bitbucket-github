## BitBucket → GitHub Migration Tools
A collection of scripts for migrating hg and git repos from BitBucket to Github.
Please edit `config.sh.example` and save it as `config.sh` to use any of them.

### Requirements
- jq [https://stedolan.github.io/jq/]
- hg-fast-export [https://github.com/frej/fast-export] * if you need to migrate mercurial repos

### Usage
#### `$ bitbucket2github.sh`
Main script, runs all the others to migrate everything it can find in the source
BitBucket account or organization to the target Github account/org.
This generates a working directory `$TMP_REPO_DIR` which is required for all the
other scripts but you could set this to anywhere. I typically use `mktemp -d` to
for this but it is perfectly valid to point them at an existing directory.

#### `$ get-bitbuckets.sh $TMP_REPO_DIR`
Queries the BitBucket API for a list of repos under an account.
It's pretty easy to set the jq filters in this script to filter the source repos
by a specific BitBucket "Project" or other metrics.
Eg, adding `select(.project.key=='EX')` to the jq lines like so:
`[.values[] | select(.scm=="hg") | select(.project.key=='EX')][].slug`

#### `$ clone-(git|hg)-repos.sh $TMP_REPO_DIR`
Copies all the git or hg repos found by `get-bitbucket.sh`. Will also get latest
in any repos that already exist in `$TMP_REPO_DIR`.

#### `$ hg-get-authors.sh $TMP_REPO_DIR`
Collects the names/emails of the mercurial repos' contributors to a map file for
hg-fast-export. You should edit the resulting file (`$TMP_REPO_DIR\authors.map`)
in order to link accounts for user that have multiple names or emails.

#### `$ hg2git.sh $TMP_REPO_DIR`
Runs `hg-fast-export` on all the found hg repos. If anything breaks, it's almost
certainly going to happen here.

#### `git2github.sh $TMP_REPO_DIR`
Creates GitHub repos for everything found above if they don not already exist on
the target account.
