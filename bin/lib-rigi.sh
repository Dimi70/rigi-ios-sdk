
# Get Rigi data folder
RIGI=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &> /dev/null && pwd)
RIGI="$RIGI/Rigi"

# No Rigi data folder?
if [ ! -d "$RIGI" ]; then
    echo "Please create a local Rigi data folder:"
    echo "  $RIGI"
    echo
    echo "Rigi command failed. 💥"
    echo
    exit 1
fi

# No Rigi ini file in Rigi folder?
if [ ! -f "$RIGI/rigi.ini" ]; then
    echo "Please add a valid 'rigi.ini' file in the local Rigi data folder:"
    echo "  $RIGI/"
    echo
    echo "A default file can be found in the Pods/Rigi/docs/rigi.ini"
    echo
    echo "Rigi command failed. 💥"
    echo
    exit 1
fi

# Load rigi settings file
source "$RIGI/rigi.ini"

# If the Xcode project is not defined, use Rigi sdk parent parent folder.
if [ -z "$XCODE_PROJECT" ]; then 
    XCODE_PROJECT=`cd "$RIGI/..";pwd`
fi

