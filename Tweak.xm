#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>

// ─── Offsets ───────────────────────────────────────────────
#define OFFSET_GOD          0x4760558
#define OFFSET_GHOST        0x4760574
#define OFFSET_WALK         0x4760590
#define OFFSET_FLY          0x47605ac
#define OFFSET_TELEPORT     0x4760650
#define OFFSET_FREEZEFRAME  0x476066c
#define OFFSET_SLOMO        0x47604d0
#define OFFSET_SUMMON       0x476026c
#define OFFSET_PLAYERSONLY  0x4760250

// ─── Memory helpers ────────────────────────────────────────
static uintptr_t getBase() {
    return (uintptr_t)_dyld_get_image_header(0);
}

static BOOL readBool(uintptr_t offset) {
    return *(BOOL *)(getBase() + offset);
}

static void writeBool(uintptr_t offset, BOOL val) {
    *(BOOL *)(getBase() + offset) = val;
}

// ─── Passthrough Window ────────────────────────────────────
@interface HNPassthroughWindow : UIWindow
@end

@implementation HNPassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Если нажатие попало на сам window (фон) — пропускаем в игру
    if (hit == self) return nil;
    return hit;
}
@end

// ─── Menu View Controller ──────────────────────────────────
@interface HNMenuVC : UIViewController
@property (nonatomic, strong) UIView      *menuPanel;
@property (nonatomic, strong) UIButton    *floatBtn;
@property (nonatomic, assign) BOOL         menuOpen;
@property (nonatomic, strong) NSArray     *labels;
@property (nonatomic, strong) NSArray     *offsets;
@property (nonatomic, strong) NSMutableArray *toggleBtns;
@end

@implementation HNMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    self.labels  = @[@"God", @"Ghost", @"Walk", @"Fly",
                     @"Teleport", @"FreezeFrame", @"Slomo",
                     @"Summon", @"PlayersOnly"];
    self.offsets = @[@(OFFSET_GOD), @(OFFSET_GHOST), @(OFFSET_WALK),
                     @(OFFSET_FLY), @(OFFSET_TELEPORT), @(OFFSET_FREEZEFRAME),
                     @(OFFSET_SLOMO), @(OFFSET_SUMMON), @(OFFSET_PLAYERSONLY)];
    self.toggleBtns = [NSMutableArray array];

    [self setupFloatButton];
    [self setupMenuPanel];
}

// ── Плавающая кнопка ──────────────────────────────────────
- (void)setupFloatButton {
    CGFloat size = 54;
    self.floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatBtn.frame = CGRectMake(20, 120, size, size);
    self.floatBtn.layer.cornerRadius = size / 2;
    self.floatBtn.clipsToBounds = YES;
    self.floatBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.85];
    self.floatBtn.layer.borderColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0].CGColor;
    self.floatBtn.layer.borderWidth = 2.0;

    // Иконка ⚙
    UILabel *icon = [[UILabel alloc] initWithFrame:self.floatBtn.bounds];
    icon.text = @"⚙️";
    icon.font = [UIFont systemFontOfSize:26];
    icon.textAlignment = NSTextAlignmentCenter;
    icon.userInteractionEnabled = NO;
    [self.floatBtn addSubview:icon];

    [self.floatBtn addTarget:self action:@selector(onFloatTap) forControlEvents:UIControlEventTouchUpInside];

    // Drag
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    [self.floatBtn addGestureRecognizer:pan];

    [self.view addSubview:self.floatBtn];
}

- (void)onDrag:(UIPanGestureRecognizer *)gr {
    CGPoint delta = [gr translationInView:self.view];
    CGPoint center = self.floatBtn.center;
    center.x += delta.x;
    center.y += delta.y;

    // Не вылетать за экран
    CGFloat half = self.floatBtn.frame.size.width / 2;
    CGSize screen = self.view.bounds.size;
    center.x = MAX(half, MIN(screen.width  - half, center.x));
    center.y = MAX(half + 44, MIN(screen.height - half - 34, center.y));

    self.floatBtn.center = center;
    [gr setTranslation:CGPointZero inView:self.view];

    // Синхронизируем позицию меню
    if (self.menuOpen) [self updateMenuPosition];
}

// ── Меню ──────────────────────────────────────────────────
- (void)setupMenuPanel {
    NSInteger count = self.labels.count;
    CGFloat rowH = 44, padV = 12, padH = 14;
    CGFloat panelH = count * rowH + padV * 2;
    CGFloat panelW = 210;

    self.menuPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, panelW, panelH)];
    self.menuPanel.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:0.93];
    self.menuPanel.layer.cornerRadius = 14;
    self.menuPanel.layer.borderColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:0.5].CGColor;
    self.menuPanel.layer.borderWidth = 1.5;
    self.menuPanel.hidden = YES;

    // Тень
    self.menuPanel.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.menuPanel.layer.shadowOpacity = 0.5;
    self.menuPanel.layer.shadowRadius  = 8;
    self.menuPanel.layer.shadowOffset  = CGSizeMake(0, 4);

    for (NSInteger i = 0; i < count; i++) {
        CGFloat y = padV + i * rowH;

        // Label
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(padH, y, 110, rowH)];
        lbl.text = self.labels[i];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [self.menuPanel addSubview:lbl];

        // Toggle button
        UIButton *toggle = [UIButton buttonWithType:UIButtonTypeCustom];
        toggle.frame = CGRectMake(panelW - padH - 60, y + 7, 60, 30);
        toggle.layer.cornerRadius = 15;
        toggle.tag = i;
        toggle.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        [toggle addTarget:self action:@selector(onToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self updateToggleAppearance:toggle isOn:NO];
        [self.menuPanel addSubview:toggle];
        [self.toggleBtns addObject:toggle];

        // Разделитель
        if (i < count - 1) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(padH, y + rowH - 0.5, panelW - padH*2, 0.5)];
            sep.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
            [self.menuPanel addSubview:sep];
        }
    }

    [self.view addSubview:self.menuPanel];
}

- (void)updateToggleAppearance:(UIButton *)btn isOn:(BOOL)on {
    if (on) {
        btn.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0];
        [btn setTitle:@"ON" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        btn.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.35 alpha:1.0];
        [btn setTitle:@"OFF" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
    }
}

- (void)updateMenuPosition {
    CGPoint fc = self.floatBtn.center;
    CGFloat pw = self.menuPanel.frame.size.width;
    CGFloat ph = self.menuPanel.frame.size.height;
    CGFloat screenW = self.view.bounds.size.width;

    // Слева или справа от кнопки
    CGFloat x = (fc.x + 30 + pw < screenW) ? fc.x + 30 : fc.x - 30 - pw;
    CGFloat y = fc.y - ph / 2;
    y = MAX(44, MIN(self.view.bounds.size.height - ph - 34, y));

    self.menuPanel.frame = CGRectMake(x, y, pw, ph);
}

- (void)onFloatTap {
    self.menuOpen = !self.menuOpen;
    if (self.menuOpen) {
        [self refreshToggles];
        [self updateMenuPosition];
        self.menuPanel.alpha = 0;
        self.menuPanel.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.menuPanel.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            self.menuPanel.alpha = 0;
        } completion:^(BOOL done) {
            self.menuPanel.hidden = YES;
        }];
    }
}

- (void)refreshToggles {
    for (NSInteger i = 0; i < self.offsets.count; i++) {
        uintptr_t off = (uintptr_t)[self.offsets[i] unsignedLongValue];
        BOOL current = readBool(off);
        UIButton *btn = self.toggleBtns[i];
        [self updateToggleAppearance:btn isOn:current];
    }
}

- (void)onToggle:(UIButton *)sender {
    NSInteger i = sender.tag;
    uintptr_t off = (uintptr_t)[self.offsets[i] unsignedLongValue];
    BOOL newVal = !readBool(off);
    writeBool(off, newVal);
    [self updateToggleAppearance:sender isOn:newVal];
}

@end

// ─── Hook AppDelegate – запускаем overlay ─────────────────
%hook AppDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)opts {
    BOOL result = %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        HNPassthroughWindow *win = [[HNPassthroughWindow alloc]
            initWithFrame:[UIScreen mainScreen].bounds];
        win.windowLevel = UIWindowLevelAlert + 100;
        win.backgroundColor = [UIColor clearColor];
        win.hidden = NO;

        HNMenuVC *vc = [[HNMenuVC alloc] init];
        win.rootViewController = vc;

        // Держим ссылку
        objc_setAssociatedObject(app, "hnTweakWindow", win, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });

    return result;
}

%end
