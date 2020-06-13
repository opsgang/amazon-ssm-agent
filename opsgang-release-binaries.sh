# vim: et sr sw=4 ts=4 smartindent syntax=sh:

# golang_version(): used in shippable to docker-pull correct golang image
git_diff_code() {
    [[ -z "$2" ]] && echo "ERROR: git_diff_code() needs branch name, artefact dir" >&2 && return 1
    local branch="$1" rd="$2"
    local tag=""

    tag="$(tag_from_branch $branch)"
    git diff -p $tag -- agent > $rd/upstream-release-$tag.diff
}

# if we build a opsgang/<tag name> branch successfully,
# create a release for <tag name>.
#
# Possibly an "opsgang/fetch"-suitable release as well
# so we can use version constraints when automating updates
# of ssm agent. WOULD REQUIRE A SEM-VER TAG AS WELL.
#
release() {
    local rd="$(pwd)/release-artefacts"
    if [[ "$BRANCH" =~ ^opsgang/[0-9\.]+$ ]]; then
        echo "... will build a release and upload artefacts"
        echo "... getting ghr from ${GHR}"
        t=$(tag_from_branch $BRANCH) || return 1
        get_ghr || return 1
        prep_release_artefacts "$rd"  || return 1
        git_diff_code "$BRANCH" "$rd" || return 1
        gh_release "$BRANCH" "$rd"
        echo "shippable vars:"
        echo "BRANCH: $BRANCH"
        echo "TAG FOR RELEASE: $t"
        echo "IS_PULL_REQUEST: $IS_PULL_REQUEST"
    else
        echo "... not a branch for packaging a release"
        echo "shippable vars:"
        echo "BRANCH: $BRANCH"
        echo "IS_PULL_REQUEST: $IS_PULL_REQUEST"
    fi
}

get_ghr() {
    local zip="/var/tmp/ghr.zip"
    local ghr_url="https://github.com/tcnksm/ghr/releases/download/v0.5.4/ghr_v0.5.4_linux_amd64.zip"
    sudo wget -O $zip "${ghr_url}" || return 1
    sudo apt-get update ; apt-get install -y zip unzip

    sudo unzip -d /usr/bin $zip && sudo rm -f $zip

    [[ -x /usr/bin/ghr ]] # success if installed
}

tag_from_branch() {
    [[ -z "$1" ]] && echo "ERROR: tag_from_branch() expects branch name" >&2 && return 1
    echo "${1##*/}"
}

prep_release_artefacts() {
    local artefact_dir="$1"
    local d="$(pwd)"
    local pd=$d/opsgang
    local bin_dir=$pd/bin
    local cfg_dir=$pd/etc/amazon/ssm
    local svc_dir=$pd/etc/systemd/system
    local uf=""
    mkdir -p $artefact_dir $bin_dir $cfg_dir $svc_dir

    echo "... copying built binaries " $(ls -1 $d/bin/linux_amd64 | grep -v updater)
    cp -a $d/bin/linux_amd64/{amazon-ssm-agent,ssm-cli,ssm-document-worker} $bin_dir

    echo "... copying default cfgs, systemd service template"
    cp -a $d/bin/amazon-ssm-agent.json.template $cfg_dir/amazon-ssm-agent.json
    cp -a $d/bin/seelog_unix.xml $cfg_dir/seelog.xml

    echo "... modifying .service unit file, then copying to $svc_dir"
    uf=$d/packaging/linux/amazon-ssm-agent.service

    sed -i '/^WorkingDirectory=/d' $uf
    sed -i '/^ExecStart=/d' $uf
    cat <<EOF | sed -i "/Type=simple/r /dev/stdin" $uf
# In this example the binaries are all in /home/core/ssm
# ... modify the paths to suit your needs ...
Environment="SSM_BIN_DIR=/home/core/ssm""
WorkingDirectory=/home/core/ssm
ExecStart=/home/core/ssm/amazon-ssm-agent
EOF
    cp $uf $svc_dir/amazon-ssm-agent.service

    tar czvf $artefact_dir/binaries.tgz -C $bin_dir .
    tar czvf $artefact_dir/default-cfgs.tgz -C $pd etc
}

gh_release() {
    [[ -z "$GITHUB_TOKEN" ]] && echo "ERROR: GITHUB_TOKEN must be exported" >&2 && return 1
    [[ -z "$2" ]] && echo "ERROR: gh_release() needs branch name, artefact dir" >&2 && return 1

    local branch="$1" rd="$2"
    local tag="" gh_org="opsgang" body="" commit=""

    tag="$(tag_from_branch $branch)"

    if ! commit=$(git rev-list -n1 $tag)
    then
        echo "ERROR: could not determine commit of tag $tag"
        return 1
    fi

    body="$(_body_txt $tag)" || return 1
    echo -e "COMMIT: $commit\nBODY:\n$body\n\nTAG:$tag\nDIR:$rd\n"

    ghr -u $gh_org -c $commit -b "$body" -recreate $tag $rd
}


_body_txt() {
    [[ -z "$1" ]] && echo "ERROR: must pass _body_txt() upstream git tag" >&2 && return 1
    local tag="$1"
    local url="https://github.com/aws/amazon-ssm-agent/releases/tag/$tag"

    echo "
_Built from sha1 $(git --no-pager rev-parse --short=8 --verify HEAD)_

**Though intended for CoreOS these binaries work on any linux amd64.**

Unlike the amazon releases, these binaries can be installed anywhere on
an instance's filesystem and the agent will still run.

Specify the path to the ssm-document-worker and other binaries
**at run-time** by setting \$SSM_BIN_DIR in the *amazon-ssm-agent's*
environment.

See the .service file in default-cfgs.tgz for a systemd example.

## ARTEFACTS

        binaries.tgz
        ├── amazon-ssm-agent
        ├── ssm-cli
        ├── ssm-document-worker
        ├── ssm-session-logger
        └── ssm-session-worker

        default-cfgs.tgz
        └── etc
            ├── amazon
            │   └── ssm
            │       ├── amazon-ssm-agent.json # example agent cfg
            │       └── seelog.xml            # agent logging props
            └── systemd
                └── system
                    └── amazon-ssm-agent.service # example systemd unit


        upstream-release-$tag.diff # between this build's code and upstream's code.

## UPSTREAM

Release notes for upstream tag $tag are here:

$url
"

}

release

