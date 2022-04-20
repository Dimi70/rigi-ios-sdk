echo "------------------------------"
echo "Rigi collect simulator preview"
echo "------------------------------"
echo

# Get Rigi skd folder
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

# Load rigi settings file
source "$DIR/rigi.ini"

# If the simulator documents folder is not defined, get the last used simulator / application folder.
if [ ! -z "$SIMULATOR_DOCUMENTS" ]; then 
    BABYLON_SNAPSHOTS="$SIMULATOR_DOCUMENTS/rigi"
else
    BABYLON_SNAPSHOTS=$(ls -dt ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Documents/rigi | head -n 1) 1> /dev/null
fi

# Simulator rigi folder exits?
if [ ! -d "$BABYLON_SNAPSHOTS" ]; then
    echo "Could not find the rigi folder in the simulator documents folder:"
    echo "  $BABYLON_SNAPSHOTS"
    echo
    echo "Rigi preview collection failed. 💥"
    echo
    exit 1
fi

# Get number of html files in simulator rigi folder
FOUND=$(ls -l $BABYLON_SNAPSHOTS | grep "html" | wc -l | xargs)

# No html files found?
if (( $FOUND == 0 )); then
    echo "No previews found in simulator folder:"
    echo "  $BABYLON_SNAPSHOTS"
    echo
    echo "Rigi preview collection failed 💥"
    echo
    exit 1
fi

echo "Found $FOUND previews in simulator documents folder:"
echo "  $BABYLON_SNAPSHOTS"
echo

# Make output filename (zip)
DATE=`date "+%Y%m%d-%H%M%S"`
ZIPNAME="previews-$DATE.zip"
ZIPFILE="$DIR/data/upload-previews/$ZIPNAME"

# Zip simulator rigi folder and count number of html files in output file (zip)
pushd "$BABYLON_SNAPSHOTS/.." 1> /dev/null
zip -r "$ZIPFILE" rigi/ 1> /dev/null
ZIPPED=$(zipinfo "$ZIPFILE" | grep "html" | wc -l  | xargs)
popd 1> /dev/null

echo "Created zip file with $ZIPPED previews:"
echo "  $ZIPFILE"
echo

echo "Rigi preview collection ready 👍"
echo "Zipfile can now be uploaded to the Rigi cloud 🚀"
echo

