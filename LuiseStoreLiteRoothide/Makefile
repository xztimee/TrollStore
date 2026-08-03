ifneq ($(THEOS_PACKAGE_SCHEME),roothide)
$(error LuiseStoreLiteRoothide requires THEOS_PACKAGE_SCHEME=roothide)
endif

TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = LuiseStoreLite
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = LuiseStoreLite

LuiseStoreLite_FILES = $(wildcard ../LuiseStore/*.m) $(wildcard ../Shared/*.m)
LuiseStoreLite_RESOURCE_DIRS = ../LuiseStoreLite/Resources
LuiseStoreLite_RESOURCE_FILES = Resources/luisestorehelper ../varClean/varClean/VarCleanRules.json ../varClean/varClean/varCleanRules_rootful_overrides.json
LuiseStoreLite_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony
LuiseStoreLite_PRIVATE_FRAMEWORKS = Preferences MobileIcons MobileContainerManager
LuiseStoreLite_LIBRARIES = archive roothide
LuiseStoreLite_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix)/opt/libarchive/include -DLUISESTORE_LITE -DLUISESTORE_ROOTHIDE
LuiseStoreLite_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
