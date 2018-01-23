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

Basically, I change a `constant` to a
`var` in the least intrusive, and utterly inelegant way possible at build time.

## WHY THIS FORK?

The motivation for this came about because:

* I want to choose where my binaries live on the hosts I manage.

* On CoreOS, recent versions of the official agent will not work, as they expect the
    doc manager to be installed under /usr/bin, which just happens to be a read-only filesystem.
    I use CoreOS. A lot.
    
* The Amazon contributors [do not have plans][3] to allow the path to the document worker to be
    configured at run-time.

* Levent Yalcin wrote [a great piece][4] about running AWS SSM on CoreOS.
    Sadly his excellent tutorial on building a CoreOS-compatible fell foul of the hard-coded path
    to the ssm document worker. Hopefully this solution helps those who find his article via
    their favourite search engine.
    
## RELEASES

The shippable build process will add successfully built binaries to the official
release tag the upstream src is from.

The only alteration to src is to allow the user to define the location
of the document worker at run-time.
