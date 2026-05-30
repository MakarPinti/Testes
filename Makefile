MODULES = jailed
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HelloNeighborTweak
DISPLAY_NAME = Hello Neighbor Tweak
BUNDLE_ID = com.mod.helloneighbortweak

HelloNeighborTweak_FILES = Tweak.xm
HelloNeighborTweak_IPA = HelloNeighbor.ipa
HelloNeighborTweak_FRAMEWORKS = UIKit Foundation
HelloNeighborTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
