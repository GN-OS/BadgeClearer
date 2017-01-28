include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BadgeClearerPreferences
BadgeClearerPreferences_FILES = BadgeClearerPreferences.mm
BadgeClearerPreferences_INSTALL_PATH = /Library/PreferenceBundles
BadgeClearerPreferences_FRAMEWORKS = UIKit
BadgeClearerPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS)/makefiles/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BadgeClearerPreferences.plist$(ECHO_END)
