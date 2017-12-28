include theos/makefiles/common.mk

SUBPROJECTS += mshufflehook
SUBPROJECTS += mshufflesettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
