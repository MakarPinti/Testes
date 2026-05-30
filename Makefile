TARGET = iphone:clang:16.5:14.0
ARCHS = arm64

TWEAK_NAME = HelloNeighborCheat
HelloNeighborCheat_FILES = Tweak.xm Menu.mm
HelloNeighborCheat_FRAMEWORKS = UIKit Foundation
HelloNeighborCheat_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
