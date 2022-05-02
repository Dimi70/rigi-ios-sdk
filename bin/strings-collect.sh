echo "-------------------------"
echo "Rigi collect string files"
echo "-------------------------"
echo

# Include the Rigi bash library
source $(dirname $0)/lib-rigi.sh



# Create the required upoload folders
mkdir -p "$RIGI/data" 1> /dev/null
mkdir -p "$RIGI/data/upload-strings" 1> /dev/null

# Make output filename (zip)
DATE=`date "+%Y%m%d-%H%M%S"`
ZIPNAME="strings-$DATE.zip"
ZIPFILE="$RIGI/data/upload-strings/$ZIPNAME"

# Get number of string files in xCode project folder (ignore files inside Pods or SDKs folder)
LIST=$(find "$XCODE_PROJECT" -name "*.strings" | grep -Ewv "Pods|SDKs")
FOUND=$(echo "$LIST" | grep "strings" | wc -l | xargs)

# No string files found?
if (( $FOUND == 0 )); then
    echo "No string files found in project folder:"
    echo "  $XCODE_PROJECT"
    echo
    echo "Rigi string collection failed 💥"
    echo
    exit 1
fi

echo "Found $FOUND string files in project folder:"
echo "  $XCODE_PROJECT"
echo

echo "Creating new zip file:"
echo "  $ZIPFILE"
echo

# Zip the string files in the Xcode project and count number of files in output file (zip)
pushd "$XCODE_PROJECT" 1> /dev/null
find . -name "*.strings" | grep -Ewv "\./Pods|\./SDKs" | zip "$ZIPFILE" -@ # 1> /dev/null
ZIPPED=$(zipinfo "$ZIPFILE" | grep "strings" | wc -l  | xargs)
popd 1> /dev/null

echo
echo "Created zip file with $ZIPPED string files:"
echo "  $ZIPFILE"
echo

echo "Rigi string collection ready 👍"
echo "Zip file can now be uploaded to the Rigi cloud 🚀"
echo
