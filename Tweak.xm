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
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *v in self.subviews) {
        if (!v.hidden && [v pointInside:[self convertPoint:point toView:v] withEvent:event])
            return YES;
    }
    return NO;
}
@end

static PassthroughWindow *overlayWindow = nil;

@interface DragButton : UIButton
@end
@implementation DragButton
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint prev = [t previousLocationInView:self.superview];
    CGPoint curr = [t locationInView:self.superview];
    CGPoint c = self.center;
    c.x += curr.x - prev.x;
    c.y += curr.y - prev.y;
    self.center = c;
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

        overlayWindow = [[PassthroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 99;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = [[UIViewController alloc] init];
        overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        // НЕ вызываем makeKeyAndVisible — игра остаётся key window
        overlayWindow.hidden = NO;

        DragButton *btn = [DragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 120, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.clipsToBounds = YES;
        btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.85];
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        [btn addTarget:[CheatMenu sharedMenu] action:@selector(toggleVisibility)
              forControlEvents:UIControlEventTouchUpInside];
        [overlayWindow.rootViewController.view addSubview:btn];
    });
}
