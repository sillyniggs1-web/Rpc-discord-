LOCAL_PATH := $(call my-dir)
# Required: path to a checkout of RusJJ/AndroidModLoader (for <mod/amlmod.h> etc.)
#   ndk-build ... AML_PATH=/path/to/AndroidModLoader
AML_PATH ?= $(LOCAL_PATH)/third_party/AndroidModLoader
ifeq ($(AML_PATH),)
$(error AML_PATH is not set. Point it to a checkout of github.com/RusJJ/AndroidModLoader)
endif
ifeq ($(wildcard $(AML_PATH)/mod/amlmod.h),)
$(error $(AML_PATH)/mod/amlmod.h not found)
endif

include $(CLEAR_VARS)
# Output: libSampDiscordRPC.so
LOCAL_MODULE := SampDiscordRPC
LOCAL_SRC_FILES := main.cpp src/logger.cpp src/config.cpp src/presence_builder.cpp src/game_adapter.cpp \
                   src/rpc_manager.cpp src/log_backend.cpp src/lifecycle.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include $(AML_PATH)
LOCAL_CPPFLAGS += -O2 -DNDEBUG -fvisibility=hidden
LOCAL_CPPFLAGS += -mfloat-abi=softfp
LOCAL_LDLIBS := -llog
LOCAL_DISABLE_NO_UNDEFINED := true   # GetInterface etc. are resolved by libAML at load time

# Optional real Discord backend. Set DISCORD_SDK_DIR to the unpacked Social SDK that contains include/discordpp.h
# and lib/<abi>/libdiscord_partner_sdk.so (extract jni/<abi>/ from the .aar into lib/<abi>/). If either is missing the build STOPS (no silent fallback).
ifneq ($(DISCORD_SDK_DIR),)
  ifeq ($(wildcard $(DISCORD_SDK_DIR)/include/discordpp.h),)
    $(error DISCORD_SDK_DIR/include/discordpp.h not found)
  endif
  ifeq ($(wildcard $(DISCORD_SDK_DIR)/lib/$(TARGET_ARCH_ABI)/libdiscord_partner_sdk.so),)
    $(error No $(TARGET_ARCH_ABI) libdiscord_partner_sdk.so in $(DISCORD_SDK_DIR)/lib/$(TARGET_ARCH_ABI))
  endif
  LOCAL_SRC_FILES += src/discord_backend.cpp
  LOCAL_C_INCLUDES += $(DISCORD_SDK_DIR)/include
  LOCAL_CPPFLAGS += -DSAMPRPC_WITH_DISCORD_SDK
  LOCAL_LDLIBS += -L$(DISCORD_SDK_DIR)/lib/$(TARGET_ARCH_ABI) -ldiscord_partner_sdk
endif
include $(BUILD_SHARED_LIBRARY)
