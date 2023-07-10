#!/bin/bash

#set -x

OPT_REPO="forcedotcom"
OPT_BRANCH="dev"
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

usage ()
{
    echo "Use this script to set generate xcframeworks for Swift Package Manager"
    echo "Usage: $0 -r org -b branch"
    echo "  where: - org is the organization of the iOS repo e.g forcedotcom"
    echo "         - branch is the branch to checkout e.g. dev"
    exit 1
}

parse_opts ()
{
    while getopts :hr:b command_line_opt
    do
        case ${command_line_opt} in
	    h)  usage ;;
            r)  OPT_REPO=${OPTARG} ;;
            b)  OPT_BRANCH=${OPTARG} ;;
        esac
    done

    if [ "${OPT_REPO}" == "" ] || [ "${OPT_BRANCH}" == "" ]
    then
        echo -e "${RED}You must specify a value for the org and branch.${NC}"
        usage
    fi
}

function header () {
    local SPACER="---------------------------------------------------------------------------"
    echo -e "${YELLOW}\n\n${SPACER}\n    $1\n${SPACER}\n${NC}"
}

function cloneRepo () {
    local repoOrg=$1
    local branch=$2
    local repo="git@github.com:${repoOrg}/SalesforceMobileSDK-iOS"
    header "Cloning ${repo}#${branch}"
    git clone --branch $branch --single-branch --depth 1 $repo
    pushd SalesforceMobileSDK-iOS
    ./install.sh
    popd
}

function buildFramework() {
    local lib=$1
    local destination=$2

    pushd SalesforceMobileSDK-iOS
    header "Building $destination archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=$destination" \
        -archivePath ../archives/$lib-iOS \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES
    popd
}

function processLib () {
    local lib=$1

    buildFramework $lib "iOS"
    buildFramework $lib "iOS Simulator"
    
    header "Building xcframework for $lib"
    pushd SalesforceMobileSDK-iOS
    xcodebuild -create-xcframework \
        -framework ../archives/$lib-iOS.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ../archives/$lib-Sim.xcarchive/Products/Library/Frameworks/$lib.framework \
        -output ../archives/$lib.xcframework
    popd

    pushd archives
    header "Zipping xcframework for $lib"
    zip $lib.xcframework.zip $lib.xcframework -r

    header "Updating checksum for $lib"
    local checksum=`swift package compute-checksum $lib.xcframework.zip`
    gsed -i "s/checksum: \"[^\"]*\" \/\/ ${lib}/checksum: \"${checksum}\" \/\/ ${lib}/g" ../Package.swift
    popd
}

function cleanup () {
    rm -rf archives/*-iOS.xcarchive
    rm -rf archives/*-Sim.xcarchive
    rm -rf archives/*.xcframework
    rm -rf SalesforceMobileSDK-iOS
}    

function generateXcFrameworks() {
    for lib in 'SalesforceSDKCommon' 'SalesforceAnalytics' 'SalesforceSDKCore' 'SmartStore' 'MobileSync'
    do
	processLib $lib
    done
}

parse_opts "$@"

# cloneRepo $OPT_REPO $OPT_BRANCH
generateXcFrameworks
cleanup
