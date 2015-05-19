
# Define target output
target: bit

# Define target part
export PRJ_PART = XC7Z045FFG900-2

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/ZynqEthernet  \
                     $(PROJ_DIR)/../../modules/ZynqEthernet10G \
                     $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/PpiCommon \
                     $(PROJ_DIR)/../../modules/MgtLib/gtx7 \
                     $(PROJ_DIR)/../../modules/pgp2b/core \
                     $(PROJ_DIR)/../../modules/pgp2b/gtx7 \
                     $(PROJ_DIR)/../../modules/PpiPgp \
                     $(PROJ_DIR)/../../modules/RceG3 \
                     $(PROJ_DIR)/../../modules/DpmCore \
                     $(PROJ_DIR)

# Use top level makefile
include ../../modules/StdLib/build/system_vivado_v1.mk
