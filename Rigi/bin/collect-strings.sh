echo "-------------------------"
echo "Rigi collect string files"
echo "-------------------------"
echo

# Get Rigi skd folder
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

# Load rigi settings file
source "$DIR/rigi.ini"

# If the Xcode project is not defined, use Rigi sdk parent parent folder.
if [ -z "$XCODE_PROJECT" ]; then 
    XCODE_PROJECT=`cd "$DIR/..";pwd`
fi

# Make output filename (zip)
DATE=`date "+%Y%m%d-%H%M%S"`
ZIPNAME="strings-$DATE.zip"
ZIPFILE="$DIR/data/upload-strings/$ZIPNAME"

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
