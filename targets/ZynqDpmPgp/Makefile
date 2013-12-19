
# Define target output
target: bit bitbin

# Define target part
export PRJ_PART = XC7Z045FFG900-1

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/ZynqEthernet  \
                     $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/processing_system7_v4_02_a  \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/ArmRceG3 \
                     $(PROJ_DIR)/../../modules/common \
                     $(PROJ_DIR)/../../modules/VcLib \
                     $(PROJ_DIR)/../../modules/pgp2/rtl/core \
                     $(PROJ_DIR)/../../modules/pgp2/rtl/gtx7 \
                     $(PROJ_DIR)/../../modules/MgtLib/gtx7 \
                     $(PROJ_DIR)

# Max number of smart explorer runs
export SMART_MAX_RUNS = 10

# Use top level makefile
#include ../../modules/StdLib/build/system_ise_v1.mk
include ../../modules/StdLib/build/system_vivado_v1.mk
