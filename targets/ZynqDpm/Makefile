
# Define target output
target: bootbin bitbin trce

# Define target part
export PRJ_PART = XC7Z045FFG900-1

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/ZynqEthernet  \
                     $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/processing_system7_v4_02_a  \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/ArmRceG3 \
                     $(PROJ_DIR)

# Max number of smart explorer runs
export SMART_MAX_RUNS = 10

# Use top level makefile
include ../../system.mk
