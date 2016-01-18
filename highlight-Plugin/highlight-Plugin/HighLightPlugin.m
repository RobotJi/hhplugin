//
//  HighLightPlugin.m
//  highlight-Plugin
//
//  Created by RobotJi on 13-7-16.
//  Copyright (c) 2013年 xiaojukeji. All rights reserved.
//

#import "HighLightPlugin.h"
#import "HighLightModel.h"


//Xcode 5.x  install path ~/Library/Application Support/Xcode/Plug-ins
//Xcode 6.x  install path ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins
//Xcode 7.x  install path ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins

/**
 *  在新版Xcode里面插件会失效，请做如下操作
 *  1、打开终端，输入：defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID
 *  命令后，会得到你的Xcode唯一串，如：7265231C-39B4-402C-89E1-16167C4CC990，
 *  2、然后打开插件安装目录（上面），找到highlight-Plugin.xcplugin，右键-显示包内容，进去之后找到Info.plist
 *  3、打开Info.plist，找到key为DVTPlugInCompatibilityUUID的array项，把刚才得到的Xcode唯一串添加进去，保存
 *  4、然后重启Xcode，记得重启后在弹出的alert里面选择load bundle
 *
 */

#define kMinCharacter 2
#define kMaxCharacter 60
#define kDDhighlightIdentifier @"com.xiaojukeji.highlight.highlight-Plugin"

static HighLightPlugin *instance;

#define DDNotifier [NSNotificationCenter defaultCenter]

@interface HighLightPlugin()
@property(atomic,strong)NSTextView *textv;
@property(atomic,copy)NSString *lastSelectedText;
@property(nonatomic,strong)HighLightModel *lightModel;
@property(nonatomic,strong)NSMenuItem *itemOpen,*itemClose;
@property(atomic)BOOL hasLight;
@property(atomic,strong)NSMutableArray *keyArr;
@property(nonatomic,strong)Class currentTextView;
@end

@implementation HighLightPlugin{
    
    dispatch_queue_t queueSelected;
}

+(void)pluginDidLoad: (NSBundle*) plugin {
    [HighLightPlugin shared];

}

+(id)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HighLightPlugin alloc]init];
    });
    
    return instance;
}


-(id)init{

    if (self = [super init]) {
        [DDNotifier addObserver:self selector:@selector(appDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
    
    return self;
}

-(void)__setupMenu{
    
    NSMenu *menu = [[NSMenu alloc]initWithTitle:@"DDHighlight"];
    _itemOpen = [[NSMenuItem alloc]initWithTitle:@"Open" action:@selector(openHighlight:) keyEquivalent:@""];

    _itemClose = [[NSMenuItem alloc]initWithTitle:@"Close" action:@selector(closeHighlight:) keyEquivalent:@""];
    
    NSMenuItem *itemColor =[[NSMenuItem alloc]initWithTitle:@"Color" action:@selector(chooseColor:) keyEquivalent:@""];
    
    [_itemOpen setTarget:self];
    [_itemClose setTarget:self];
    [itemColor setTarget:self];
    
    [menu addItem:_itemOpen];
    [menu addItem:_itemClose];
    [menu addItem:itemColor];
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *itemAbout = [[NSMenuItem alloc]initWithTitle:@"About" action:@selector(aboutPlugin:) keyEquivalent:@""];
    [itemAbout setTarget:self];
    [menu addItem:itemAbout];
    
    NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:@"Syntax Highlight" action:NULL keyEquivalent:@""];
    [item setSubmenu:menu];
    [[NSApp mainMenu]addItem:item];
    
    BOOL state = self.lightModel.lightState.boolValue;

    if (state) {
        [_itemOpen setState:NSOnState];
        [self __setupObserver:YES];
    }else{
        [_itemClose setState:NSOnState];
    }

}

-(void)__setupObserver:(BOOL)isStart{
    
    [DDNotifier removeObserver:self name:NSTextViewDidChangeSelectionNotification object:nil];
    
    if (isStart) {
        //IDEBuildOperationWillStartNotification
        //IDEBuildOperationDidStopNotification
        [DDNotifier addObserver:self selector:@selector(textSelected:) name:NSTextViewDidChangeSelectionNotification object:nil];
//        [DDNotifier addObserver:self selector:@selector(textSelected:) name:nil object:nil];
    }
    
}

-(void)__setupData{
    self.lightModel = [[HighLightModel alloc]init];
    NSData *archData = [[NSUserDefaults standardUserDefaults]objectForKey:kHighLight];
    if (archData) {
        id model = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
        if ([model isKindOfClass:[HighLightModel class]]) {
            self.lightModel = (HighLightModel *)model;
        }
    }
    
    NSBundle *bd = [NSBundle bundleWithIdentifier:kDDhighlightIdentifier];
    NSString *pth = [bd pathForResource:@"highlight-exkeyword" ofType:@"plist"];
    NSDictionary *ddic = [[NSDictionary alloc] initWithContentsOfFile:pth];
    if (ddic.count > 0) {
        NSArray *arrs = [ddic objectForKey:@"keywords"];
        if ([arrs isKindOfClass:[NSArray class]]&&arrs.count > 0) {
            self.keyArr = [[NSMutableArray alloc] initWithArray:arrs];
        }
    }
    
    if (!self.keyArr) {
        NSLog(@"exkeyword error...............");
    }
}

-(void)appDidFinishLaunching:(NSNotification *)noti{
    queueSelected = dispatch_queue_create("com.xiaojukeji.highlightplugin", DISPATCH_QUEUE_SERIAL);
    self.currentTextView = NSClassFromString(@"DVTSourceTextView");
    
    [self __setupData];
    [self __setupMenu];

}

-(void)textSelected:(NSNotification *)noti{
    
    if (![noti.object isKindOfClass:[NSTextView class]]) {
        return ;
    }
    
    dispatch_async(queueSelected, ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            Class currentTextView = NSClassFromString(@"DVTSourceTextView");
            if (self.currentTextView != [noti.object class]) {
                return ;
            }
            self.textv = (NSTextView *)noti.object;
            if (self.textv.selectedRanges.count == 0) {
                return;
            }
            NSString *selectedText = [[self.textv.textStorage.string substringWithRange:_textv.selectedRange]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([self.lastSelectedText isEqualToString:selectedText]) {
                return;
            }

            [self removeColorAttribute];
            
            if ([self needSkipCharacter:selectedText]) {
                return ;
            }

            [self regsearch:selectedText];
            
        });
        
    });
}

-(BOOL)needSkipCharacter:(NSString *)character{
    //这里先简单粗暴判断，满足大部分情况吧
    return character.length < kMinCharacter || character.length > kMaxCharacter || [self.keyArr containsObject:character];
}

-(void)removeColorAttribute{
    @try {
        if (self.hasLight) {
            NSTextStorage *mulStr = [self.textv textStorage];
            NSRange range = NSMakeRange(0, mulStr.string.length);
            [mulStr removeAttribute:NSBackgroundColorAttributeName range:range];
//            [mulStr addAttribute:NSBackgroundColorAttributeName value:self.textv.backgroundColor range:range];
            [mulStr ensureAttributesAreFixedInRange:range];
            self.hasLight = NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception========%@____desc:::%@",exception,exception.description);
    }
    @finally {
        self.lastSelectedText = nil;
    }
}

-(void)regsearch:(NSString *)searchStr{

    if (self.textv.textStorage.string.length == 0) {
        return;
    }
    
    NSString *pattern = [NSString stringWithFormat:@"[^a-zA-Z0-9_]%@[^a-zA-Z0-9_]",searchStr];
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray *rels = [reg matchesInString:self.textv.textStorage.string options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.textv.textStorage.string.length-1)];
    if (rels.count == 0) {
        return;
    }
    NSTextStorage *mulStr = [self.textv textStorage];
    NSUInteger length = [self.textv.textStorage string].length;

    for (NSTextCheckingResult *match in rels) {
        NSRange range = NSMakeRange(match.range.location+1, match.range.length-2);//去除正则匹配带来的range问题
        if (range.length > kMaxCharacter || range.location+range.length > length) {
            continue;
        }
        [mulStr addAttribute:NSBackgroundColorAttributeName value:self.lightModel.colorHighlight range:range];
        [mulStr ensureAttributesAreFixedInRange:range];
    }

    self.hasLight = YES;
    self.lastSelectedText = searchStr;

}

-(void)openHighlight:(id)sender{
    [self __setupObserver:YES];
    self.lightModel.lightState = @1;
    [self saveLighModel];
    [self changeMenuItemStyle];
}

-(void)closeHighlight:(id)sender{
    [self __setupObserver:NO];
    self.lightModel.lightState = @0;
    [self saveLighModel];
    [self changeMenuItemStyle];
    [self removeColorAttribute];
}

-(void)changeMenuItemStyle{
    if (self.lightModel.lightState.boolValue) {
        [_itemOpen setState:NSOnState];
        [_itemClose setState:NSOffState];
    }else{
        [_itemOpen setState:NSOffState];
        [_itemClose setState:NSOnState];
    }
}

-(void)aboutPlugin:(id)sender{

    NSBundle *bd = [NSBundle bundleWithIdentifier:kDDhighlightIdentifier];
    NSString *notice = [bd objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
    
    NSAlert *alt = [NSAlert alertWithMessageText:@"关于" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"开发人员可以自由使用\n%@\n",notice];//
    [alt runModal];
}

/*
 默认选中颜色
 13-7-22 下午6:56:41.506 Xcode: dic-------->{
 NSBackgroundColor = "NSCalibratedRGBColorSpace 0.655013 0.787977 1 1";
 }

 */

-(void)chooseColor:(id)sender{

    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    [panel orderFront:nil];
    [panel setAction:@selector(choosed:)];
    [panel setTarget:self];
    [panel makeKeyAndOrderFront:self];
    [panel center];
    [self removeColorAttribute];
}

-(void)choosed:(id)sender{
    if ([sender isKindOfClass:[NSColorPanel class]]) {
        NSColorPanel *panel = (NSColorPanel *)sender;
        self.lightModel.colorHighlight = panel.color;
        [self saveLighModel];
    }
}

-(void)saveLighModel{
    NSData *archData = [NSKeyedArchiver archivedDataWithRootObject:self.lightModel];
    [[NSUserDefaults standardUserDefaults]setObject:archData forKey:kHighLight];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end

