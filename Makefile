include theos/makefiles/common.mk

TWEAK_NAME = MShuffle
MShuffle_FILES = /mnt/d/codes/mshuffle/Tweak.xm
MShuffle_FRAMEWORKS = CydiaSubstrate Foundation UIKit MediaPlayer
MShuffle_PRIVATE_FRAMEWORKS = MediaRemote MediaPlayerUI
MShuffle_CFLAGS = -fobjc-arc
MShuffle_LDFLAGS = -Wl,-segalign,4000

MShuffle_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
