#import <UIKit/UIKit.h>
#import "Menu.h"

@interface PassthroughWindow : UIWindow
@end
@implementation PassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Пропускаем только сам фон окна, кнопка остаётся кликабельной
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
        gestureWindow.hidden = NO;
        [gestureWindow makeKeyAndVisible];

        // Плавающая кнопка
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 120, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.clipsToBounds = YES;
        btn.backgroundColor = [[UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.85];
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        [btn addTarget:[CheatMenu sharedMenu] action:@selector(toggleVisibility) forControlEvents:UIControlEventTouchUpInside];

        // Drag
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:nil];
        [pan addTarget:btn action:nil];
        __block CGPoint lastLocation;
        void (^panHandler)(UIPanGestureRecognizer *) = ^(UIPanGestureRecognizer *gr) {
            CGPoint delta = [gr translationInView:gestureWindow];
            CGPoint center = btn.center;
            center.x += delta.x;
            center.y += delta.y;
            btn.center = center;
            [gr setTranslation:CGPointZero inView:gestureWindow];
        };
        objc_setAssociatedObject(pan, "handler", panHandler, OBJC_ASSOCIATION_COPY);
        [pan addTarget:btn action:nil];

        UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:gestureWindow action:nil];
        [gestureWindow addSubview:btn];

        // Проще — используем отдельныйViewController
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        gestureWindow.rootViewController = vc;

        UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatBtn.frame = CGRectMake(20, 120, 50, 50);
        floatBtn.layer.cornerRadius = 25;
        floatBtn.clipsToBounds = YES;
        floatBtn.backgroundColor = [[UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.85];
        [floatBtn setTitle:@"⚙️" forState:UIControlStateNormal];
        floatBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [floatBtn addTarget:[CheatMenu sharedMenu] action:@selector(toggleVisibility) forControlEvents:UIControlEventTouchUpInside];
        [vc.view addSubview:floatBtn];
    });
}
