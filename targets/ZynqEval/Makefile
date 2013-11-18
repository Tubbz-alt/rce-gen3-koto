
# Define target output
target: bit bitbin trce

# Define target part
export PRJ_PART = XC7Z020CLG484-1

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/processing_system7_v4_02_a  \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/ArmRceG3 \
                     $(PROJ_DIR)/../../modules/common   \
                     $(PROJ_DIR)

# Max number of smart explorer runs
export SMART_MAX_RUNS = 10

# Uncomment to use chipscope core inserter
#CHIPSCOPE_INSERTER_EN = 1

# Use top level makefile
include ../../system_ise.mk
