#!/usr/bin/env bash
set -e

ls -la


cd npm/
ls -la
mkdir ${GITHUB_WORKSPACE}/dist
npm pack --workspaces --pack-destination=${GITHUB_WORKSPACE}/dist


ls -la ${GITHUB_WORKSPACE}/dist
pwd

cd ../
npm pack --pack-destination=${GITHUB_WORKSPACE}/dist
