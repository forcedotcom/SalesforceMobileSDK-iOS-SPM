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

function buildSQLCipher() {
    local destination=$1
    local suffix=$2
    
    header "Building SQLCipher static library for $destination"
    
    # Clone SQLCipher if not already present
    if [ ! -d "sqlcipher" ]; then
        git clone --branch v4.10.0 --depth 1 https://github.com/sqlcipher/sqlcipher.git
    fi
    
    pushd sqlcipher
    
    # Configure build settings based on destination
    local sdk=""
    local arch=""
    local min_version=""
    
    case $destination in
        "iOS")
            sdk="iphoneos"
            arch="arm64"
            min_version="17.0"
            ;;
        "iOS Simulator")
            sdk="iphonesimulator" 
            arch="arm64 x86_64"
            min_version="17.0"
            ;;
        "visionOS")
            sdk="xros"
            arch="arm64"
            min_version="2.0"
            ;;
        "visionOS Simulator")
            sdk="xrsimulator"
            arch="arm64 x86_64" 
            min_version="2.0"
            ;;
    esac
    
    # Clean previous builds
    make clean || true
    
    # Configure and build SQLCipher static library
    ./configure \
        --enable-tempstore=yes \
        --with-crypto-lib=commoncrypto \
        --disable-tcl \
        --enable-static \
        --disable-shared \
        CPPFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLCIPHER_CRYPTO_CC" \
        CFLAGS="-arch $arch -isysroot $(xcrun --sdk $sdk --show-sdk-path) -m${sdk/simulator/}-version-min=$min_version -fembed-bitcode"
    
    make sqlite3.c
    
    # Build the static library
    mkdir -p ../sqlcipher-libs/$suffix
    xcrun clang -c sqlite3.c -o ../sqlcipher-libs/$suffix/sqlite3.o \
        -arch $arch \
        -isysroot $(xcrun --sdk $sdk --show-sdk-path) \
        -m${sdk/simulator/}-version-min=$min_version \
        -DSQLITE_HAS_CODEC \
        -DSQLITE_TEMP_STORE=2 \
        -DSQLCIPHER_CRYPTO_CC \
        -fembed-bitcode
    
    ar rcs ../sqlcipher-libs/$suffix/libsqlcipher.a ../sqlcipher-libs/$suffix/sqlite3.o
    
    # Copy headers
    mkdir -p ../sqlcipher-libs/$suffix/include
    cp sqlite3.h ../sqlcipher-libs/$suffix/include/
    
    popd
}

function buildFMDB() {
    local destination=$1
    local suffix=$2
    
    header "Building FMDB static library for $destination"
    
    # Clone FMDB if not already present
    if [ ! -d "fmdb" ]; then
        git clone --branch v2.7.12 --depth 1 https://github.com/ccgus/fmdb.git fmdb
    fi
    
    pushd fmdb
    
    # Configure build settings based on destination
    local sdk=""
    local arch=""
    local min_version=""
    
    case $destination in
        "iOS")
            sdk="iphoneos"
            arch="arm64"
            min_version="17.0"
            ;;
        "iOS Simulator")
            sdk="iphonesimulator" 
            arch="arm64 x86_64"
            min_version="17.0"
            ;;
        "visionOS")
            sdk="xros"
            arch="arm64"
            min_version="2.0"
            ;;
        "visionOS Simulator")
            sdk="xrsimulator"
            arch="arm64 x86_64" 
            min_version="2.0"
            ;;
    esac
    
    # Create output directory
    mkdir -p ../fmdb-libs/$suffix
    
    # Compile FMDB source files to object files
    local sources=(
        "src/fmdb/FMDatabase.m"
        "src/fmdb/FMDatabaseAdditions.m" 
        "src/fmdb/FMDatabasePool.m"
        "src/fmdb/FMDatabaseQueue.m"
        "src/fmdb/FMResultSet.m"
    )
    
    local objects=()
    for source in "${sources[@]}"; do
        local basename=$(basename "$source" .m)
        local objfile="../fmdb-libs/$suffix/${basename}.o"
        objects+=("$objfile")
        
        xcrun clang -c "$source" -o "$objfile" \
            -arch $arch \
            -isysroot $(xcrun --sdk $sdk --show-sdk-path) \
            -m${sdk/simulator/}-version-min=$min_version \
            -I../sqlcipher-libs/$suffix/include \
            -DSQLITE_HAS_CODEC \
            -DFMDB_SQLITE_STANDALONE \
            -fembed-bitcode \
            -fobjc-arc
    done
    
    # Create static library from object files
    ar rcs ../fmdb-libs/$suffix/libfmdb.a "${objects[@]}"
    
    # Copy headers
    mkdir -p ../fmdb-libs/$suffix/include
    cp src/fmdb/*.h ../fmdb-libs/$suffix/include/
    
    popd
}

function buildFramework() {
    local lib=$1
    local destination=$2
    local suffix=$3

    pushd SalesforceMobileSDK-iOS
    header "Building $destination archive for $lib"
    
    # Special handling for SmartStore to statically embed SQLCipher and FMDB
    if [ $lib == "SmartStore" ]
    then
        header "Building SmartStore with embedded SQLCipher and FMDB static libraries"
        xcodebuild archive \
            -workspace SalesforceMobileSDK.xcworkspace \
            -scheme $lib \
            -destination "generic/platform=$destination" \
            -archivePath ../archives/$lib-$suffix \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
            OTHER_LDFLAGS="\$(inherited) -L../sqlcipher-libs/$suffix -L../fmdb-libs/$suffix -lsqlcipher -lfmdb -framework Security" \
            HEADER_SEARCH_PATHS="\$(inherited) ../sqlcipher-libs/$suffix/include ../fmdb-libs/$suffix/include" \
            OTHER_SWIFT_FLAGS="\$(inherited) -DSQLITE_HAS_CODEC=1" \
            GCC_PREPROCESSOR_DEFINITIONS="\$(inherited) SQLITE_HAS_CODEC=1"
    else
        # Standard build for other frameworks
        xcodebuild archive \
            -workspace SalesforceMobileSDK.xcworkspace \
            -scheme $lib \
            -destination "generic/platform=$destination" \
            -archivePath ../archives/$lib-$suffix \
            SKIP_INSTALL=NO \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES
    fi
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
    if ! zip $lib.xcframework.zip $lib.xcframework -r; then
        echo "Error: $lib.xcframework not found or zip failed."
        exit 1
    fi
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

    # Build SQLCipher and FMDB static libraries before building SmartStore
    if [ $lib == "SmartStore" ]
    then
        header "Pre-building SQLCipher and FMDB static libraries for SmartStore"
        buildSQLCipher "iOS" "iOS"
        buildSQLCipher "iOS Simulator" "Sim"
        buildSQLCipher "visionOS" "visionOS"
        buildSQLCipher "visionOS Simulator" "visionOS-Sim"
        
        buildFMDB "iOS" "iOS"
        buildFMDB "iOS Simulator" "Sim"
        buildFMDB "visionOS" "visionOS"
        buildFMDB "visionOS Simulator" "visionOS-Sim"
    fi

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
    rm -rf sqlcipher
    rm -rf sqlcipher-libs
    rm -rf fmdb
    rm -rf fmdb-libs
}    

parse_opts "$@"
cloneRepo $OPT_REPO $OPT_BRANCH
for lib in 'SalesforceSDKCommon' 'SalesforceAnalytics' 'SalesforceSDKCore' 'SmartStore' 'MobileSync'
do
    processLib $lib
done
cleanup
