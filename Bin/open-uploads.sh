echo "------------------------"
echo "Rigi open uploads folder"
echo "------------------------"
echo

# Get Rigi skd folder
DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

# Load rigi settings file
source "$DIR/rigi.ini"

UPLOADS="$DIR/data/upload-previews/"

# Uploads rigi folder exits?
if [ ! -d "$UPLOADS" ]; then
    echo "Could not find the rigi uploads folder in the current project:"
    echo "  $UPLOADS"
    echo
    echo "Rigi open uploads folder failed. 💥"
    echo
    exit 1
fi

open "$UPLOADS" 1> /dev/null

echo "Rigi uploads folder opened in finder:"
echo "  $UPLOADS"
echo

