//
//  KFLOverlayWindowController.m
//  villain
//
//  Created by Fredrik Andersson on 2012-02-20.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//
#import <Carbon/Carbon.h>
#import "KFLOverlayWindowController.h"
#import "KFLOverlayWindow.h"
#import "KFLElement.h"
#import <QuartzCore/QuartzCore.h>
#import "KFLUtils.h"

@implementation KFLOverlayWindowController
@synthesize items, filter, delegate, screenHeight, screenWidth;

- (id)initWithWindow:(KFLOverlayWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        self.items = [NSMutableArray new];

        [window setDelegate:self];
        
        self.screenHeight = self.window.frame.size.height;
        self.screenWidth = self.window.frame.size.width;
        
        self.filter = @"";
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)close {
    [super close];
    
    [self.delegate windowClosed:self];
}

- (void)dealloc {
}
- (void)annotate:(NSString*)text 
      onPosition:(CGPoint)pos 
     withElement:(KFLElement*)element {
    
    text = [text kvcasedString];
    
    NSUInteger labelWidth  = 40;
    NSUInteger labelHeight = 20;
    
    NSTextField *tf = [[NSTextField alloc] initWithFrame:
                       NSMakeRect(pos.x+labelWidth <= screenWidth ? pos.x : screenWidth-labelWidth, 
                                  screenHeight-pos.y-labelHeight, 
                                  labelWidth, 
                                  labelHeight)];
    
    [tf setTextColor:[NSColor whiteColor]];
    [tf setBackgroundColor:[NSColor colorWithCalibratedRed:0.2 
                                                     green:0.2 
                                                      blue:0.6 
                                                     alpha:0.75]];
    [tf setBordered:YES];
    [tf setEditable:NO];
    [tf setAlignment:NSCenterTextAlignment];
    [tf setStringValue:text];
    
    KFLTuple *t = [[KFLTuple alloc] initWithA:tf 
                                         andB:element 
                                         andC:text];
    
    [self.items addObject:t];
    
    [self.window.contentView addSubview:tf];
}
- (NSArray*)hitTest:(NSString*)chars {
    if([chars length] == 0) {
        return self.items;
    }
    NSMutableArray *result = [NSMutableArray new];
    
    for (KFLTuple *t in self.items) {
        NSString *text = t.c;
        
        if ([text hasPrefix:chars]) {
            [result addObject:t];
        }
    }
    
    return [NSArray arrayWithArray:result];
}
- (void)updateHit:(NSArray*)hit 
         andUnhit:(NSArray*)unhit {
    for (KFLTuple* t in hit) {
        NSTextField *tf = [t a];
        
        [tf setAlphaValue:1.0];
    }
    for (KFLTuple* t in unhit) {
        NSTextField *tf = [t a];
        
        [tf setAlphaValue:0.2];
    }
}
- (void)character:(NSString*)character 
         withCode:(ushort)code {
    
    NSString *current = filter;
    NSString *modified = filter;

    if (code == 51) {        
        NSUInteger length = [modified length];
        
        modified = length == 0 ? modified : [modified substringToIndex:length-1];
    } else if(code == 53) {
        modified = @"";
        
        [self close];
    } else {        
        NSString *chr = [character kvcasedString];

        modified = [modified stringByAppendingString:chr];
    }
    
    if (![current isEqualToString:modified]) {
        NSArray *hit = [self hitTest:modified];
        NSArray *unhit = [items arrayByRemovingObjectsFromArray:hit];
        
        if([hit count] == 1) {
            KFLElement *element = [[hit objectAtIndex:0] b];
            
            self.filter = @"";
            
            [self close];
            
            [element press];
            
        } else if([hit count] > 1) {
            
            self.filter = modified;
            
            [self updateHit:hit 
                   andUnhit:unhit];
        }
    }    
}

-(void)makeKeyAndOrderFront {
    [self.window makeKeyAndOrderFront:nil];
    
    KFLElement *application = [KFLElement thisApplication];
    
    [application setFrontmost:YES];
    
    NSArray* windows = [application allWindows];
    KFLElement *window = [windows objectAtIndex:0];
    
    [window setMain:YES];
}

+(KFLOverlayWindowController*)windowForScreen:(NSScreen*)screen {
    
    KFLOverlayWindow *w = [[KFLOverlayWindow alloc] initWithScreen:screen];
    KFLOverlayWindowController *wc = [[KFLOverlayWindowController alloc] initWithWindow:w];
    
    [wc makeKeyAndOrderFront];

    return wc;
}

+(KFLOverlayWindowController*)createWindows {
    return nil;
}

@end
