# SYNCING UPSTREAM

## Update Fork's master

```bash
# Keep master in sync with upstream
git checkout master
git remote add upstream https://github.com/aws/amazon-ssm-agent
git fetch upstream
git merge upstream/master

# ... push release tags to origin or we can't upload binaries to them!
git push -u origin master ; git push --tags
```

```bash
# for a new release tag on master (of form x.y.z.0)
_tag=x.y.z.0
git checkout released
git checkout -b coreos/$_tag
git merge $_tag

# now verify that no new /usr/bin paths have been introduced
# and that DefaultDocumentWorker is still being used to init
# the process
e.g.
    grep -rl /usr/bin .
    grep -rl DefaultDocumentWorker .

# ONCE YOU ARE HAPPY WITH ANY CHANGES
git push -u origin/coreos/$_tag ; git push --tags
```

```bash
# after a successful, verified build of new release tag
_tag=x.y.z.0
git checkout -b coreos/$_tag
git checkout released ; git pull --prune
git merge coreos/$_tag
git push -u origin/released
```
