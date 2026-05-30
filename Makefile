TARGET = iphone:clang:16.5:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HelloNeighborTweak
HelloNeighborTweak_FILES = Tweak.xm
HelloNeighborTweak_FRAMEWORKS = UIKit Foundation
HelloNeighborTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
