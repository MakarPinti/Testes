include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HelloNeighborTweak
HelloNeighborTweak_FILES = Tweak.xm
HelloNeighborTweak_FRAMEWORKS = UIKit Foundation
HelloNeighborTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
