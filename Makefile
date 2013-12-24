include ./theos/makefiles/common.mk

TWEAK_NAME = BadgeClearer
BadgeClearer_FILES = Tweak.xm

SUBPROJECTS += BCPreferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
