include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BadgeClearer
BadgeClearer_FILES = Tweak.xm

SUBPROJECTS += badgeclearerpreferences

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"