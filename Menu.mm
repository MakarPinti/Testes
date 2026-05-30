#import "Menu.h"
#import <mach-o/dyld.h>

#define OFFSET_GOD         0x104760558
#define OFFSET_GHOST       0x104760574
#define OFFSET_WALK        0x104760590
#define OFFSET_FLY         0x1047605ac
#define OFFSET_TELEPORT    0x104760650
#define OFFSET_FREEZEFRAME 0x10476066c
#define OFFSET_SLOMO       0x1047604d0
#define OFFSET_SUMMON      0x10476026c
#define OFFSET_PLAYERSONLY 0x104760250

typedef void (*ConsoleCmd)(void);

static void callCommand(uintptr_t va_offset) {
    uintptr_t slide = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "HelloNeighbor")) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    ((ConsoleCmd)(va_offset + slide))();
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
        @[@"God Mode",     @(OFFSET_GOD)],
        @[@"Ghost",        @(OFFSET_GHOST)],
        @[@"Walk",         @(OFFSET_WALK)],
        @[@"Fly",          @(OFFSET_FLY)],
        @[@"Teleport",     @(OFFSET_TELEPORT)],
        @[@"Freeze Frame", @(OFFSET_FREEZEFRAME)],
        @[@"Slomo",        @(OFFSET_SLOMO)],
        @[@"Summon",       @(OFFSET_SUMMON)],
        @[@"Players Only", @(OFFSET_PLAYERSONLY)],
    ];

    _panel = [[UIView alloc] initWithFrame:CGRectMake(80, 60, 220, 50 + commands.count * 38 + 8)];
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
        btn.tag = [commands[i][1] integerValue];
        [btn addTarget:self action:@selector(commandTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_panel addSubview:btn];
    }
}

- (void)commandTapped:(UIButton *)sender {
    callCommand((uintptr_t)sender.tag);
}

- (void)show  { _panel.hidden = NO; _visible = YES; }
- (void)hide  { _panel.hidden = YES; _visible = NO; }
- (void)toggleVisibility { _visible ? [self hide] : [self show]; }

@end
