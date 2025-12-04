export EMBEDDED_ROOT_HELPER ?= 0
export LEGACY_CT_BUG ?= 0

TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = LuiseStorePersistenceHelper

ifdef CUSTOM_ARCHS
ARCHS = $(CUSTOM_ARCHS)
else
ARCHS = arm64
endif

ifneq ($(LEGACY_CT_BUG),1)
TARGET_CODESIGN = ../Exploits/fastPathSign/fastPathSign
endif

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = LuiseStorePersistenceHelper

LuiseStorePersistenceHelper_FILES = $(wildcard *.m) $(wildcard ../Shared/*.m)
LuiseStorePersistenceHelper_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony
LuiseStorePersistenceHelper_PRIVATE_FRAMEWORKS = Preferences MobileContainerManager
LuiseStorePersistenceHelper_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix)/opt/libarchive/include

ifeq ($(LEGACY_CT_BUG),1)
LuiseStorePersistenceHelper_CODESIGN_FLAGS = -Sentitlements.plist -K../legacy.p12
LuiseStorePersistenceHelper_CFLAGS += -DLEGACY_CT_BUG=1
else
LuiseStorePersistenceHelper_CODESIGN_FLAGS = --entitlements entitlements.plist
endif

ifeq ($(EMBEDDED_ROOT_HELPER),1)
LuiseStorePersistenceHelper_CFLAGS += -DEMBEDDED_ROOT_HELPER=1
LuiseStorePersistenceHelper_FILES += $(wildcard ../RootHelper/*.m)
LuiseStorePersistenceHelper_LIBRARIES += archive
LuiseStorePersistenceHelper_PRIVATE_FRAMEWORKS += SpringBoardServices BackBoardServices FrontBoardServices
endif

include $(THEOS_MAKE_PATH)/application.mk