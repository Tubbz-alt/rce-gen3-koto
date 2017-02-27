
# Setup environment
source /mnt/host/epics/base-3.15.1/settings.sh

# Package directories
export ROGUE_DIR=`dirname ${PWD}/rogue`
export SURF_DIR=`dirname ${PWD}/../submodules/surf/`
export RCE_DIR=`dirname ${PWD}/../submodules/rce-gen3-fw-lib/`

# Setup python path
export PYTHONPATH=${ROGUE_DIR}/python:${SURF_DIR}/python:${RCE_DIR}/python:${PYTHONPATH}

# Setup library path
export LD_LIBRARY_PATH=${ROGUE_DIR}/lib:${LD_LIBRARY_PATH}

