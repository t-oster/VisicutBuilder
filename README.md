# VisicutBuilder
A Docker container, which builds the latest VisiCut version for all platforms

this is a work in progress. In theory you should be able to run
`docker-compose up`

and get all the latest development snapshot from github compiled and packaged for every platform

## Paths/Volumes
 * `/app/build` the base folder for all build-related stuff. Is already a volume
 * `/app/build/VisiCut` is where the repository will be checked out.
 * `/app/output` the base forder for binaries. Is already a volume.
 * `/app/output/branch-$BRANCH` is where binaries for the current branch are stored

## Environment Variables
 * VISICUT_REPO: URL or Path (must be mounted as volume if it's a path) to a VisiCut Git Repository. Default: https://github.com/t-oster/VisiCut.git
