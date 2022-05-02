echo "--------------------------------"
echo "Rigi open strings uploads folder"
echo "--------------------------------"
echo

# Include the Rigi bash library
source $(dirname $0)/lib-rigi.sh

UPLOADS="$RIGI/data/upload-strings/"

# No Rigi uploads folder exits?
if [ ! -d "$UPLOADS" ]; then
    echo "Could not find the rigi strings uploads folder:"
    echo "  $UPLOADS"
    echo
    echo "Rigi strings open failed. 💥"
    echo
    exit 1
fi

open "$UPLOADS" 1> /dev/null

echo "Rigi strings uploads folder opened in finder:"
echo "  $UPLOADS"
echo

