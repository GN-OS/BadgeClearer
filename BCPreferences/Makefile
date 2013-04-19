include theos/makefiles/common.mk

BUNDLE_NAME = BCPreferences
BCPreferences_FILES = BCPreferences.mm 
BCPreferences_INSTALL_PATH = /Library/PreferenceBundles
BCPreferences_FRAMEWORKS = UIKit
BCPreferences_PRIVATE_FRAMEWORKS = Preferences AppSupport

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BCPreferences.plist$(ECHO_END)
