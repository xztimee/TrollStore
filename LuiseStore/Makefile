TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = LuiseStore
ARCHS = arm64

TARGET_CODESIGN = ../Exploits/fastPathSign/fastPathSign

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = LuiseStore

LuiseStore_FILES = $(wildcard *.m) $(wildcard ../Shared/*.m)
LuiseStore_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony
LuiseStore_PRIVATE_FRAMEWORKS = Preferences MobileIcons MobileContainerManager
LuiseStore_LIBRARIES = archive
LuiseStore_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix)/opt/libarchive/include
LuiseStore_CODESIGN_FLAGS = --entitlements entitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
