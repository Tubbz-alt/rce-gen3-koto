
# Setup environment
source /mnt/host/epics/base-3.15.1/settings.sh
source /mnt/host/rogue/setup_rce.sh

# Package directories
export SURF_DIR=${PWD}/../submodules/surf/
export RCE_DIR=${PWD}/../submodules/rce-gen3-fw-lib/

# Setup python path
export PYTHONPATH=${SURF_DIR}/python:${RCE_DIR}/python:${PYTHONPATH}


