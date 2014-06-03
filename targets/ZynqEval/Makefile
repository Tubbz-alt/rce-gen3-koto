
# Define target output
target: bit

# Define target part
export PRJ_PART = XC7Z020CLG484-1

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/PpiCommon \
                     $(PROJ_DIR)/../../modules/RceG3 \
                     $(PROJ_DIR)/../../modules/EvalCore \
                     $(PROJ_DIR)

# Use top level makefile
include ../../modules/StdLib/build/system_vivado_v1.mk
