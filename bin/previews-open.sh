echo "--------------------------------"
echo "Rigi open preview uploads folder"
echo "--------------------------------"
echo

# Include the Rigi bash library
source $(dirname $0)/lib-rigi.sh

UPLOADS="$RIGI/data/upload-previews/"

# No Rigi uploads folder exits?
if [ ! -d "$UPLOADS" ]; then
    echo "Could not find the rigi preview uploads folder:"
    echo "  $UPLOADS"
    echo
    echo "Rigi preview open failed. 💥"
    echo
    exit 1
fi

open "$UPLOADS" 1> /dev/null

echo "Rigi preview uploads folder opened in finder:"
echo "  $UPLOADS"
echo

