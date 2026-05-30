#import <UIKit/UIKit.h>
#import "Menu.h"

@interface PassthroughWindow : UIWindow
@property (nonatomic, strong) UIButton *floatBtn;
@end

@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil;
    return hit;
}
@end

static PassthroughWindow *gestureWindow = nil;

@interface DragButton : UIButton
@end
@implementation DragButton
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint prev = [t previousLocationInView:self.superview];
    CGPoint curr = [t locationInView:self.superview];
    CGPoint center = self.center;
    center.x += curr.x - prev.x;
    center.y += curr.y - prev.y;
    self.center = center;
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

        gestureWindow = [[PassthroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        gestureWindow.windowLevel = UIWindowLevelAlert + 99;
        gestureWindow.backgroundColor = [UIColor clearColor];
        gestureWindow.hidden = NO;

        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        gestureWindow.rootViewController = vc;
        [gestureWindow makeKeyAndVisible];

        DragButton *btn = [DragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 120, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.clipsToBounds = YES;
        btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.85];
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        [btn addTarget:[CheatMenu sharedMenu] action:@selector(toggleVisibility)
              forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:btn];
    });
}
