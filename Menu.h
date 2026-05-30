#pragma once
#import <UIKit/UIKit.h>

@interface CheatMenu : UIWindow
+ (instancetype)sharedMenu;
- (void)show;
- (void)hide;
- (BOOL)isVisible;
- (void)toggleVisibility;
@end
