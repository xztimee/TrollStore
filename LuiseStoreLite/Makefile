TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = LuiseStoreLite
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = LuiseStoreLite

LuiseStoreLite_FILES = $(wildcard ../LuiseStore/*.m) $(wildcard ../Shared/*.m)
LuiseStoreLite_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony
LuiseStoreLite_PRIVATE_FRAMEWORKS = Preferences MobileIcons MobileContainerManager
LuiseStoreLite_LIBRARIES = archive
LuiseStoreLite_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix libarchive)/include -DLUISESTORE_LITE
LuiseStoreLite_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
