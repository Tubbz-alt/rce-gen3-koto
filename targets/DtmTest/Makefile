
# Define target output
target: bit bitbin

# Define target part
export PRJ_PART = XC7Z030FBG484-2

# List of build core directories.
export MODULE_DIRS = $(PROJ_DIR)/../../modules/ZynqEthernet  \
                     $(PROJ_DIR)/../../modules/StdLib  \
                     $(PROJ_DIR)/../../modules/ZynqPcieMaster \
                     $(PROJ_DIR)/../../modules/i2c_core  \
                     $(PROJ_DIR)/../../modules/RceG3 \
                     $(PROJ_DIR)/../../modules/MgtLib/gtx7 \
                     $(PROJ_DIR)/../../modules/pgp2b/core \
                     $(PROJ_DIR)/../../modules/pgp2b/gtx7 \
                     $(PROJ_DIR)/../../modules/CobTiming \
                     $(PROJ_DIR)/../../modules/DtmCore \
                     $(PROJ_DIR)

# Use top level makefile
include ../../modules/StdLib/build/system_vivado_v1.mk
