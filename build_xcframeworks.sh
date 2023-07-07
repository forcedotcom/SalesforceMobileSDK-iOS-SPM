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

function processLib () {
    local lib=$1

    pushd SalesforceMobileSDK-iOS
    header "Building iOS archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=iOS" \
        -archivePath ../archives/$lib-iOS \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    header "Building iOS simulator archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=iOS Simulator" \
        -archivePath ../archives/$lib-Sim \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    header "Building xcframework for $lib"
    xcodebuild -create-xcframework \
        -framework ../archives/$lib-iOS.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ../archives/$lib-Sim.xcarchive/Products/Library/Frameworks/$lib.framework \
        -output ../archives/$lib.xcframework
    popd

    header "Zipping xcframework for $lib"
    pushd archives
    zip $lib.xcframework.zip $lib.xcframework -r
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

cloneRepo $OPT_REPO $OPT_BRANCH
generateXcFrameworks
cleanup
