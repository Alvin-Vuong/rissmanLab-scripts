#!/bin/sh
###################################################################################
# license_listen.sh
#
# This script listens on the MATLAB Statistics Toolbox licenses to see if any are
# available.  If so, it will run the specified MATLAB script.
#
###################################################################################

# Specified script
script='/space/raid6/data/rissman/Nicco/NIQ/Scripts/Workspace_Running.m'

# Listen on license status
while [ $( lmstat -a | grep Statistics_Toolbox: | sed 's/^.*Total of \([0-9]\) .*/\1/' ) -eq 8 ]
do
  echo "Licenses are all taken at the moment..."
  sleep 5s
done

# Run script
echo "At least one license is open, starting script."
matlab -nojvm < $script
echo "Script finished!"
