#pragma once
#import <UIKit/UIKit.h>

@interface DragButton : UIButton
@end

@interface CheatMenu : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) UIView *panel;
- (void)toggleVisibility;
@end
