# AMAZON SSM AGENT BINARIES

_for CoreOS, and actually any linux amd64_

Don't feel consigned to the /usr/bin!

Run the ssm binaries from anywhere on your filesystem.

## WHAT?

The official aws/amazon-ssm-agent src hard-codes the path
to the ssm-document-manager binary in the code for the agent.

The opsgang builds allow the agent to get the path from
an env var at run-time.

## WHY?

The motivation for this came about because:

* I want to choose where the ssm binaries live on my hosts

* On CoreOS the official agent will not work, as it expects the
    doc manager to be installed under /usr/bin, which just happens
    to be a read-only filesystem.
    
* The Amazon contributors have good reasons why the path will remain hard-coded,
    and do not have plans to allow it to be configured at run-time.
    
## Releases

The shippable build process will add successfully built binaries to the official
release tag the upstream src is from.

The only alteration to src is to allow the user to define the location
of the document worker at run-time. Basically, I change a `constant` to a
`var` in the least intrusive, and utterly inelegant way possible at build time.
