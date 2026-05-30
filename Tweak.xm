#import <UIKit/UIKit.h>
#import "Menu.h"

@interface PassthroughWindow : UIWindow
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self || hit == self.rootViewController.view) return nil;
    return hit;
}
@end

static PassthroughWindow *overlayWindow = nil;

static void setupOverlay(void) {
    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]] && 
            s.activationState == UISceneActivationStateForegroundActive) {
            scene = (UIWindowScene *)s;
            break;
        }
    }
    if (!scene) return;

    overlayWindow = [[PassthroughWindow alloc] initWithWindowScene:scene];
    overlayWindow.windowLevel = UIWindowLevelAlert + 99;
    overlayWindow.backgroundColor = [UIColor clearColor];
    overlayWindow.rootViewController = [[UIViewController alloc] init];
    overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
    overlayWindow.hidden = NO;

    CheatMenu *menu = [CheatMenu sharedInstance];
    [overlayWindow.rootViewController.view addSubview:menu.panel];

    DragButton *btn = [DragButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 120, 50, 50);
    btn.layer.cornerRadius = 25;
    btn.clipsToBounds = YES;
    btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.85];
    [btn setTitle:@"⚙️" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:22];
    [btn addTarget:menu action:@selector(toggleVisibility)
          forControlEvents:UIControlEventTouchUpInside];
    [overlayWindow.rootViewController.view addSubview:btn];
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            setupOverlay();
        });
}
