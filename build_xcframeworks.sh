#!/bin/bash

#set -x

OPT_REPO="forcedotcom"
OPT_BRANCH="dev"
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
    while getopts :hr:b: command_line_opt
    do
        case ${command_line_opt} in
	    h)  usage ;;
            r)  OPT_REPO=${OPTARG} ;;
            b)  OPT_BRANCH=${OPTARG} ;;
        esac
    done
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
    local suffix=$3

    pushd SalesforceMobileSDK-iOS
    header "Building $destination archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=$destination" \
        -archivePath ../archives/$lib-$suffix \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES
    popd

    if [ $lib == "SmartStore" ]
    then
        header "Fix swiftinterface for $lib $destination"
        find archives/$lib-$suffix.xcarchive -name "*.swiftinterface" -exec gsed -i "s/${lib}\.//g" {} \;
    fi
}

function buildXCFramework () {
    local lib=$1

    pushd SalesforceMobileSDK-iOS
    header "Building xcframework for $lib"
    xcodebuild -create-xcframework \
        -framework ../archives/$lib-iOS.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ../archives/$lib-Sim.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ../archives/$lib-visionOS.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ../archives/$lib-visionOS-Sim.xcarchive/Products/Library/Frameworks/$lib.framework \
        -output ../archives/$lib.xcframework
    popd
}

function zipXCFramework () {
    local lib=$1

    pushd archives
    header "Zipping xcframework for $lib"
    zip $lib.xcframework.zip $lib.xcframework -r
    popd
}

function updateChecksum () {
    local lib=$1
    local checksum=`swift package compute-checksum archives/$lib.xcframework.zip`

    header "Updating checksum for $lib"
    gsed -i "s/checksum: \"[^\"]*\" \/\/ ${lib}/checksum: \"${checksum}\" \/\/ ${lib}/g" Package.swift
}

function processLib () {
    local lib=$1

    buildFramework $lib "iOS" "iOS"
    buildFramework $lib "iOS Simulator" "Sim"
    buildFramework $lib "visionOS" "visionOS"
    buildFramework $lib "visionOS Simulator" "visionOS-Sim"
    buildXCFramework $lib
    zipXCFramework $lib
    # Using path instead of url / checksum in Package.swift - so checksum calculation is not needed
    # updateChecksum $lib
}

function cleanup () {
    rm -rf archives/*.xcarchive
    rm -rf archives/*.xcframework
    rm -rf SalesforceMobileSDK-iOS
}    

parse_opts "$@"
cloneRepo $OPT_REPO $OPT_BRANCH
for lib in 'SalesforceSDKCommon' 'SalesforceAnalytics' 'SalesforceSDKCore' 'SmartStore' 'MobileSync'
do
    processLib $lib
done
cleanup
