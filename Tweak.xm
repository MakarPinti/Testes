#import <UIKit/UIKit.h>
#import "Menu.h"

@interface PassthroughWindow : UIWindow
@end
@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil;
    return hit;
}
@end

static PassthroughWindow *gestureWindow = nil;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
        gestureWindow = [[PassthroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        gestureWindow.windowLevel = UIWindowLevelAlert + 99;
        gestureWindow.backgroundColor = [UIColor clearColor];
        gestureWindow.userInteractionEnabled = YES;
        gestureWindow.hidden = NO;
        [gestureWindow makeKeyAndVisible];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:[CheatMenu sharedMenu] action:@selector(toggleVisibility)];
        tap.numberOfTouchesRequired = 4;
        tap.numberOfTapsRequired = 1;
        [gestureWindow addGestureRecognizer:tap];
    });
}
