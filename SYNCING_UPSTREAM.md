# SYNCING UPSTREAM

```bash
git checkout master
git remote add upstream https://github.com/aws/amazon-ssm-agent
git fetch upstream
git merge upstream/master

# now verify that no new /usr/bin paths have been introduced
# and that DefaultDocumentWorker is still being used to init
# the process
e.g.
    grep -rl /usr/bin .
    grep -rl DefaultDocumentWorker .

# ONCE YOU ARE HAPPY WITH THE CHANGES
git commit -am 'merged upstream' ; git push -u origin master ; git push --tags
```

