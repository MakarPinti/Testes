#import <UIKit/UIKit.h>
#import "Menu.h"

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

        // Берём существующее окно игры — не создаём новое!
        UIWindow *gameWindow = [UIApplication sharedApplication].keyWindow;
        if (!gameWindow) return;

        DragButton *btn = [DragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 120, 50, 50);
        btn.layer.cornerRadius = 25;
        btn.clipsToBounds = YES;
        btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.85];
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        [btn addTarget:[CheatMenu sharedInstance] action:@selector(toggleVisibility)
              forControlEvents:UIControlEventTouchUpInside];

        [gameWindow addSubview:btn];
        [gameWindow addSubview:[CheatMenu sharedInstance].panel];
    });
}
