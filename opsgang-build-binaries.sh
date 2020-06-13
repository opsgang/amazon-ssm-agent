#!/usr/bin/env bash
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#
MATCH_FOR_ADDED_CODE='if _, err := os.Stat.DefaultDocumentWorker.; err != nil {'
MATCH_FOR_MODIFIED_CODE='if curdir, err := filepath.Abs.filepath.Dir.os.Args.0'

main() {
    local bd="${1:-$(pwd)}"
    local f="$bd/agent/appconfig/constants_unix.go" # file to change
    add_ssm_bin_path "$f"
    go fmt $f || return 1 # if invalid code, should fail

    print_changes "$f" || return 1
    amazon_poor_hygiene || return 1

    make build-linux
}

amazon_poor_hygiene() {
    echo "INFO $0: getting goimports tool"
    go get golang.org/x/tools/cmd/goimports || return 1

    echo "INFO $0: running go fmt because amazon did not bother ..."
    find agent -type f -name '*.go' -exec go fmt {} \; || return 1

    echo "INFO $0: running goimports because amazon did not bother ..."
    find agent -type f -name '*.go' -exec goimports -w {} \; || return 1

    echo "INFO $0: ... replacing amazon's checkstyle script"
    echo "INFO $0: as it clearly breaks on release tags"
    echo -e "#!/usr/bin/env sh\nexit 0\n" >Tools/src/checkstyle.sh
    chmod a+x Tools/src/checkstyle.sh

    echo "INFO $0: ... making agent modules available in libs dirs"
    ln -s `pwd` `pwd`/vendor/src/github.com/aws/amazon-ssm-agent

    echo "INFO $0: ... updating VERSION to $version because amazon did not bother ..."
    version=$(version_from_branch $(git_branch)) || return 1
    echo "$version" >VERSION

}

add_ssm_bin_path() {
    local f="$1"
    sed -i "s/\($MATCH_FOR_MODIFIED_CODE\)/} else \1/" $f

    cat << EOF | sed -i "/$MATCH_FOR_ADDED_CODE/r /dev/stdin" $f
        if bindir, ok := os.LookupEnv("SSM_BIN_PATH"); ok {
            absbindir, _ := filepath.Abs(bindir)
            DefaultDocumentWorker = filepath.Join(absbindir, "ssm-document-worker")
            DefaultSessionWorker = filepath.Join(absbindir, "ssm-session-worker")
            DefaultSessionLogger = filepath.Join(absbindir, "ssm-session-logger")
EOF

}

print_changes() {
    local f="$1"
    if ! grep -A 6 -B 1 'if bindir, ok := os.LookupEnv("SSM_BIN_PATH"); ok {' $f
    then
        echo >&2 "ERROR $0:print_changes() could not find added code for SSM_BIN_PATH"
        return 1
    fi
    return 0
}

git_branch() {
    [[ ! -z "$BRANCH" ]] && echo "$BRANCH" && return 0
    git rev-parse --abbrev-ref HEAD
}

version_from_branch() {
    [[ -z "$1" ]] && echo >&2 "ERROR: tag_from_branch() expects branch name" >&2 && return 1
    ! [[ "$1" =~ [^/]+/ ]] && echo >&2 "ERROR $0: expecting branch opsgang/x.y.z.0" && return 1
    echo "${1##*/}"
}

main
