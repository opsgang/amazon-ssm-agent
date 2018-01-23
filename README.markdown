[1]: https://github.com/aws/amazon-ssm-agent "upstream repo on github"
[2]: https://github.com/aws/amazon-ssm-agent/blob/master/agent/appconfig/constants_unix.go "culprit"
[3]: https://github.com/aws/amazon-ssm-agent/issues/76#issuecomment-348329917 "AWS say no!"
[4]: https://medium.com/levops/how-to-work-with-aws-simple-system-manager-on-coreos-4741853dfd50 "read this"

# AMAZON SSM AGENT BINARIES

_for CoreOS, and actually any linux amd64_

Don't feel consigned to the /usr/bin!

Run the ssm binaries from anywhere on your filesystem.

## CONTRIBUTING TO THIS FORK

_Note that the only purpose of this fork is to build linux amd64_
_ssm binaries from the src of an upstream release, warts, bugs and all_.

Therefore, If you have PRs for bug-fixes or features of the amazon-ssm-agent,
please open those on the [upsteam][1] as per the offical [contributing guidelines](CONTRIBUTING.md).

## WHAT?

The official aws/amazon-ssm-agent src [hard-codes the path][2]
to the ssm-document-manager binary as the `constant DefaultDocumentWorker`
in the code for the agent.

These opsgang builds modify the src to allow the agent to get the path from
an env var at run-time instead.

The only alteration to the upstream src happens at build-time and is to allow the user
to define the location of the document worker at run-time.

Basically, the build scripts change a `constant` to a `var` in the least intrusive, and utterly
inelegant way possible at build time.

## WHY THIS FORK?

The motivation for this came about because:

* I want to choose where my binaries live on the hosts I manage.

* On CoreOS, recent versions of the official agent will not work, as they expect the
    doc manager to be installed under /usr/bin, which just happens to be a read-only filesystem.
    I use CoreOS. A lot.
    
* The Amazon contributors [do not have plans][3] to allow the path to the document worker to be
    configured at run-time. Otherwise I'd just have submitted a PR ...

* Levent Yalcin wrote [a great piece][4] about running AWS SSM on CoreOS.
    Sadly his excellent tutorial on building a CoreOS-compatible fell foul of the hard-coded path
    to the ssm document worker. Hopefully this solution helps those who find his article via
    their favourite search engine.
    
## WHY NOT COMMIT THE MODIFIED CODE?

I don't want to deal with merge conflicts every time I sync with the upstream.
It is far easier to maintain hackery in _new_ files which don't exist in the upstream.

However for the curious or cautious, a diff is attached to each release showing any variations in the
src code from that of the upstream.

These are the only changes you should see:

* All occurrences in code, of /aws/amazon-ssm-agent are replaced with /opsgang/amazon-ssm-agent

* The constant `DefaultDocumentWorker` is turned in to a var

## RELEASES

The shippable build process will on success, create a git release in this fork,adding the built binaries
to the appropriate tag. (The tags used are the same as those from the upstream).

The release artefacts:

        binaries.tgz
        ├── amazon-ssm-agent
        ├── ssm-cli
        └── ssm-document-worker


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

