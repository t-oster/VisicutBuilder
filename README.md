# VisicutBuilder
A Docker container, which builds the latest VisiCut version for all platforms

If you just want to build VisiCut, you can use the prebuild docker-image from https://gitlab.com/t-oster/visicutbuildservice/container_registry.

In order to get the latest biaries you can just run

`docker run -v /tmp/output:/app/output registry.gitlab.com/t-oster/visicutbuildservice`

If you have yourself a VisiCut Source-Tree checked out at /home/foo/VisiCut you can build it with:

`docker run -v /home/foo/VisiCutBuild:/app/output -v /home/foo/VisiCut:/app/build/VisiCut -e VISICUT_UPDATE=false registry.gitlab.com/t-oster/visicutbuildservice`

You can also clone this repository and just run
`docker-compose up`

and get all the latest development snapshot from github compiled and packaged for every platform

## Paths/Volumes
 * `/app/build` the base folder for all build-related stuff. Is already a volume
 * `/app/build/VisiCut` is where the repository will be checked out.
 * `/app/output` the base forder for binaries. Is already a volume.
 * `/app/output/branch-$BRANCH` is where binaries for the current branch are stored

## Environment Variables
 * `VISICUT_REPO`: URL or Path (must be mounted as volume if it's a path) to a VisiCut Git Repository. Default: https://github.com/t-oster/VisiCut.git
 * `VISICUT_UPDATE`: do a checkout, clean and pull of VISICUT_BRANCH before build.
 * `VISICUT_BRANCH`: Branch to be checked out and pulled if VISICUT_UPDATE == true
