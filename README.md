# rea-tarball-inspector
Inspect Raku REA tarballs for legacy file extensions

## What does this script do?
This script recursively searches for tarball files in Raku's REA repository
to find the newest tarball for each distribution. Next, the newest tarball for each
distribution is searched for any outdated file extensions, namely:
.t, .pm, .pm6

## How to run this script?
* Clone the repository at https://github.com/Raku/REA repository
* Add this script to the top level directory of the repo and execute it
