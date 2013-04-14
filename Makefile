include theos/makefiles/common.mk

TWEAK_NAME = BadgeClearer
BadgeClearer_FRAMEWORKS = UIKit
BadgeClearer_FILES = Tweak.xm

SUBPROJECTS += prefs

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
