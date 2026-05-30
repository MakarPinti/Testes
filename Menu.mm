#import "Menu.h"
#import <mach-o/dyld.h>

static uintptr_t getSlide(void) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "HelloNeighbor"))
            return _dyld_get_image_vmaddr_slide(i);
    }
    return 0;
}

// Глобальные указатели на IConsoleCommand* объекты (из бинаря версии 2.3.12)
#define GLOBAL_FLY          0x671a760
#define GLOBAL_FREEZEFRAME  0x671a768
#define GLOBAL_GHOST        0x671a770
#define GLOBAL_GOD          0x671a778
#define GLOBAL_PLAYERSONLY  0x671a798
#define GLOBAL_SLOMO        0x671a7c8
#define GLOBAL_SUMMON       0x671a7e8
#define GLOBAL_TELEPORT     0x671a7f0

typedef void (*ExecFn)(uintptr_t self, const wchar_t *args, uintptr_t world, uintptr_t output);

static void callCommand(uintptr_t global_offset) {
    uintptr_t slide = getSlide();
    if (!slide) return;

    // Читаем IConsoleCommand* из глобала
    uintptr_t *global_ptr = (uintptr_t *)(global_offset + slide);
    uintptr_t cmd_obj = *global_ptr;
    if (!cmd_obj) return;  // команда ещё не инициализирована движком

    // Вызываем Execute через vtable (slot 3 в IConsoleCommand)
    uintptr_t *vtable = *(uintptr_t **)cmd_obj;
    ((ExecFn)vtable[3])(cmd_obj, L"", 0, 0);
}

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

@implementation CheatMenu {
    BOOL _visible;
    NSArray *_globals;
}

+ (instancetype)sharedInstance {
    static CheatMenu *i;
    static dispatch_once_t t;
    dispatch_once(&t, ^{ i = [[CheatMenu alloc] init]; });
    return i;
}

- (instancetype)init {
    self = [super init];
    [self buildPanel];
    return self;
}

- (void)buildPanel {
    NSArray *commands = @[
        @[@"God Mode",     @(GLOBAL_GOD)],
        @[@"Ghost",        @(GLOBAL_GHOST)],
        @[@"Fly",          @(GLOBAL_FLY)],
        @[@"Teleport",     @(GLOBAL_TELEPORT)],
        @[@"Freeze Frame", @(GLOBAL_FREEZEFRAME)],
        @[@"Slomo",        @(GLOBAL_SLOMO)],
        @[@"Summon",       @(GLOBAL_SUMMON)],
        @[@"Players Only", @(GLOBAL_PLAYERSONLY)],
    ];

    NSMutableArray *globals = [NSMutableArray array];
    for (NSArray *cmd in commands) {
        [globals addObject:cmd[1]];
    }
    _globals = [globals copy];

    CGFloat h = 50 + commands.count * 38 + 8;
    _panel = [[UIView alloc] initWithFrame:CGRectMake(80, 60, 220, h)];
    _panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    _panel.layer.cornerRadius = 14;
    _panel.layer.borderWidth = 1.5;
    _panel.layer.borderColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0].CGColor;
    _panel.hidden = YES;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 220, 25)];
    title.text = @"HN Cheat Menu";
    title.textColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:14];
    [_panel addSubview:title];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(192, 6, 24, 24);
    [close setTitle:@"X" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [_panel addSubview:close];

    for (NSInteger i = 0; i < (NSInteger)commands.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(15, 40 + i * 38, 190, 32);
        btn.backgroundColor = [[UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.15];
        btn.layer.cornerRadius = 8;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:0.4].CGColor;
        [btn setTitle:commands[i][0] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.tag = i;
        [btn addTarget:self action:@selector(commandTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_panel addSubview:btn];
    }
}

- (void)commandTapped:(UIButton *)sender {
    callCommand([_globals[sender.tag] unsignedIntegerValue]);
}

- (void)show { _panel.hidden = NO; _visible = YES; }
- (void)hide { _panel.hidden = YES; _visible = NO; }
- (void)toggleVisibility { _visible ? [self hide] : [self show]; }

@end
