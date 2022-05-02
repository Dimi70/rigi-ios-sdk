echo "----------------------------"
echo "Rigi open simulator previews"
echo "----------------------------"
echo

# Include the Rigi bash library
source $(dirname $0)/lib-rigi.sh

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
    echo "Rigi preview open failed. 💥"
    echo
    exit 1
fi

open "$BABYLON_SNAPSHOTS" 1> /dev/null

echo "Rigi previews folder opened in finder:"
echo "  $BABYLON_SNAPSHOTS"
echo

