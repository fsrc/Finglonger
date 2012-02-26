//
//  KFLLongKeysManager.m
//  villain
//
//  Created by Fredrik Andersson on 2012-02-23.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import "KFLLongKeysManager.h"
#import "KFLElement.h"
#import "KFLUtils.h"
/*
 REFERENCE:
 
    kCGWindowBounds
        Height = 693;
        Width = 1280;
        X = 0;
        Y = 22;
    kCGWindowLayer = 0;
    kCGWindowNumber = 18792;
    kCGWindowOwnerName = Xcode;
    kCGWindowOwnerPID = 11668;
    kCGWindowWorkspace = 15911;
*/


@interface Window : NSObject
    @property (assign) CGRect frame;
    @property (assign) int32_t number;
    @property (assign) int32_t pid;
    @property (retain) NSString* name;
    @property (assign) BOOL main;
    @property (assign) BOOL valid;
    @property (assign) int depth;

    @property (retain) KFLElement *application;
    @property (retain) KFLElement *window;

@end

@implementation Window
@synthesize 
    frame, 
    number, 
    pid,
    name,
    main,
    valid,
    depth,

    application,
    window;

- (id)initWithDictionary:(NSDictionary*)dict 
                andDepth:(int)z {
    self = [super init];
    if (self) {
        CGRect f;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)[dict objectForKey:@"kCGWindowBounds"], &f);
        
        NSString *windowName = [dict objectForKey:@"kCGWindowName"];
        
        self.depth = z;
        self.frame = f;
        self.number = [[dict objectForKey:@"kCGWindowNumber"] intValue];
        self.pid = [[dict objectForKey:@"kCGWindowOwnerPID"] intValue];
        self.name = windowName != nil ? windowName : @"";
        self.valid = NO;
    }
    return self;
}
- (void)updateWithAccessibility {
    self.application = [KFLElement applicationWithPid:self.pid];
    
    NSArray* windows = [self.application allWindows];
    
    for (KFLElement *w in windows) {
        CGPoint p = [w position];
        CGSize s = [w size];

        if(CGPointEqualToPoint(p, self.frame.origin) 
           && CGSizeEqualToSize(s, self.frame.size)) {
            self.window = w;
            self.valid = YES;
        }
    }
    
    if([self.window hasMain]) {
        self.main = [self.window main];
    }
}
@end

@implementation NSMutableArray(WindowStack)

-(void)addWindow:(Window*)win {
    [self addObject:win];
}

@end

@implementation KFLLongKeysManager
@synthesize 
    activeController, 
    frontmost,
    characters,
    power1,
    power2,
    power3,
    power4,
    firstChar,
    power1ary,
    power2ary,
    power3ary,
    power4ary;

- (NSString*)convertDecimal:(NSUInteger)decimal 
                     toBase:(NSUInteger)base {
    
    if(decimal == 0) return self.firstChar;
    
    NSMutableString *result = [NSMutableString new];
    do{
        UniChar c = [self.characters characterAtIndex:decimal%base];
        
        [result appendString:[NSString stringWithCharacters:&c length:1]];

        decimal /= base; // Calculate new value of decimal
    }while(decimal != 0); // Do while used for slight optimisation
  
    return [NSString stringWithString:result];//[result reverseString];
}

- (NSArray*)arrayFrom:(NSUInteger)a 
                   to:(NSUInteger)b {
    NSMutableArray *result = [NSMutableArray new];
    NSUInteger base = self.characters.length;
    
    for(NSUInteger i = a; i < b; i++) {
        [result addObject:[self convertDecimal:i toBase:base]];
    }
    return [NSArray arrayWithArray:result];
}

- (id)init {
    self = [super init];
    if (self) {
        self.characters = @"asdfjklgh";
        
        UniChar c = [characters characterAtIndex:0];
        
        self.firstChar = [NSString stringWithCharacters:&c length:1];
        
        self.power1 = [self.characters length];
        self.power2 = pow(self.characters.length, 2);
        self.power3 = pow(self.characters.length, 3);
        self.power4 = pow(self.characters.length, 4);
        
        self.power1ary = [characters arrayOfCharacters];
        self.power2ary = [self arrayFrom:self.characters.length to:self.power2];
        self.power3ary = [self arrayFrom:self.power2 to:self.power3];
        self.power4ary = [self arrayFrom:self.power3 to:self.power4];        

        self.power2 = self.power1ary.count+1;
        self.power3 = self.power2ary.count+1;
        self.power4 = self.power3ary.count+1;
    }
    return self;
}
+ (NSArray *)visibleWindows {
    NSArray *windows = (__bridge NSArray*)CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly |
                                                                     kCGWindowListExcludeDesktopElements, 
                                                                     kCGNullWindowID);
    NSMutableArray *stack = [NSMutableArray new];
    
    int z = 0;
    
    for (NSDictionary* window in windows) {
        NSString *ownerName = [window objectForKey:@"kCGWindowOwnerName"];
        
        if (![ownerName isEqualTo:@"Window Server"] && ![ownerName isEqualTo:@"Dock"]) {
            Window *w = [[Window alloc] initWithDictionary:window 
                                                  andDepth:z];
            
            [w updateWithAccessibility];
            
            if ([w valid]) {
                [stack addWindow:w];
            }
        }
        z++;
    }
    
    return [NSArray arrayWithArray:stack];
}
+ (Window *)mainWindow:(NSArray*)windows {
    for (Window *w in windows) {
        if([w main] && [w.application frontmost]) {
            return w;
        }
    }
    return nil;
}
+ (KFLTuple*)hintFromElement:(KFLElement*)element 
                   andWindow:(Window*)window {
    NSNumber *num = [NSNumber numberWithInt:window.depth];

    return [[KFLTuple alloc] initWithA:element 
                                  andB:num];
}
+ (NSArray*)hintsFromElementArray:(NSArray*)elements
                         andWindow:(Window*)window {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:elements.count];
    for (KFLElement* element in elements) {
        [result addObject:[KFLLongKeysManager hintFromElement:element 
                                                    andWindow:window]];
    }
    return [NSArray arrayWithArray:result];
}
+ (NSArray*)hintsFromWindows:(NSArray*)windows {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (Window *w in windows) {
        // MANAGE MENU IF FRONTMOST APPLICATION
        if([w main] && 
           [w.application frontmost] && 
           [w.application hasMenuBar]) {
            
            KFLElement *menu = [w.application menuBar];
            NSArray *menuChildren = [menu children];
            
            for (KFLElement* child in menuChildren) {
                if ([child hasPosition]) {
                    [items addObject:[KFLLongKeysManager hintFromElement:child 
                                                               andWindow:w]];
                }
            }            
        }
        
        // ADD ALL DEEP CHILDS
        [items addObjectsFromArray:[KFLLongKeysManager hintsFromElementArray:[w.window nodes]
                                                                   andWindow:w]];
    }
    
    return [NSArray arrayWithArray:items];
}

- (BOOL)isActive {
    return self.activeController != nil;
}
- (void)windowClosed:(id)sender {
    KFLElement *app = self.frontmost.application;
    KFLElement *win = self.frontmost.window;
    
    [app setFrontmost:YES];
    [win setMain:YES];
    
    self.activeController = nil;
    self.frontmost = nil;
}
- (void)hideHints {
    [self.activeController close];
}

- (BOOL)hitTest:(CGPoint)point 
        atDepth:(int)z 
     forWindows:(NSArray*)windows {
    if (z != 0) {
        for (Window* w in windows) {
            if(z > w.depth && CGRectContainsPoint(w.frame, point))
                return YES;
        }
    }
    return NO;
}

- (void)showHints {
    
    NSArray *visible = [KFLLongKeysManager visibleWindows];
    NSArray *hints = [KFLLongKeysManager hintsFromWindows:visible];
    NSScreen *screen = [NSScreen mainScreen];
        
    self.frontmost = [KFLLongKeysManager mainWindow:visible];
    self.activeController = [KFLOverlayWindowController windowForScreen:screen];
    self.activeController.delegate = self;
    
    NSUInteger hintCount = hints.count;
    
    NSArray *texts =    hintCount < power2-1 ? power1ary :
                        hintCount < power3-1 ? power2ary :
                        hintCount < power4-1 ? power3ary :
                        power4ary;
    
    int co = 0;
    for (KFLTuple* hint in hints) {
        int depth = [[hint b] intValue];
        KFLElement *element = [hint a];
        CGPoint pos = [element position];

        if(![self hitTest:pos 
                  atDepth:depth 
               forWindows:visible]) {
            
            NSString *text = [texts objectAtIndex:co];
            
            [self.activeController annotate:text 
                                 onPosition:pos
                                withElement:element];
            
            co++;
        }
    }
}

@end
