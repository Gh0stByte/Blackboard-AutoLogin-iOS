include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BlackBoardHVCCAutoLogin
BlackBoardHVCCAutoLogin_FILES = Tweak.xm
BlackBoardHVCCAutoLogin_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 BbStudent"

