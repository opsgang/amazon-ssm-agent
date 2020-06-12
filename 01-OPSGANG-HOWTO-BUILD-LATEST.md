# OPSGANG: HOWTO build latest upstream tag

## Update master

> Keep master in sync with upstream - we **never** change master.

```bash
git checkout master
git remote add upstream https://github.com/aws/amazon-ssm-agent
git fetch upstream
git pull upstream master
git reset --hard upstream/master
git push -f origin master

# ... push release tags to origin or we can't upload binaries to them!
git push -u origin master ; git push --tags
```

>
> Compare agent/appconfig/constants\_unix.go in previous built
> release and tag you wish to build. If there are changes in that
> or in the build-linux target in the makefile, we may need
> to update our modification code.
>

```bash
# for a new release tag on master (of form x.y.z.0)
_tag=x.y.z.0 tmpdir=opsgang-tmp
git checkout opsgang-build-artefacts # branch with our base code on it, not in sync with master
mkdir $tmpdir; cp opsgang*.sh shippable.yml $tmpdir;
git checkout $_tag ; git checkout -b opsgang/$_tag ;
mv $tmpdir/* . ; rmdir $tmpdir
git add --all ; git commit -am 'added assets for custom build and release'


# ONCE YOU ARE HAPPY WITH ANY CHANGES
git push -u origin opsgang/$_tag ; git push --tags
```

```bash
# after a successful, verified build of new release tag
_tag=x.y.z.0 tmpdir=opsgang-tmp
git checkout -b opsgang/$_tag ;
mkdir $tmpdir; cp opsgang*.sh shippable.yml $tmpdir;
git checkout opsgang-build-artefacts
mv $tmpdir/* . ; rmdir $tmpdir
git add --all ; git commit -am 'assets for custom build and release'
git push -u origin opsgang-build-artefacts
```
