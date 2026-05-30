#import <UIKit/UIKit.h>

static UIWindow *hnWindow;

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    if (hnWindow) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0*NSEC_PER_SEC)),
    dispatch_get_main_queue(), ^{
        hnWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        hnWindow.windowLevel = UIWindowLevelAlert + 100;
        hnWindow.backgroundColor = [UIColor clearColor];
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20,100,200,50)];
        lbl.text = @"Tweak loaded!";
        lbl.textColor = [UIColor greenColor];
        [vc.view addSubview:lbl];
        hnWindow.rootViewController = vc;
        hnWindow.hidden = NO;
    });
}

%end
