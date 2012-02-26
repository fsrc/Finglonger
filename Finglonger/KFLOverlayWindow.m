//
//  KFLOverlayWindow.m
//  villain
//
//  Created by Fredrik Andersson on 2012-02-20.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import "KFLOverlayWindow.h"
#import "KFLOverlayWindowController.h"
#import "KFLOverlayView.h"

@implementation KFLOverlayWindow

-(BOOL)canBecomeKeyWindow {
    return YES;
}
-(BOOL)canBecomeMainWindow {
    return YES;
}
- (void)dealloc {
}
- (id)initWithScreen:(NSScreen*)screen {
    NSRect screenRect = [screen frame];
    
    self = [super initWithContentRect:screenRect
                            styleMask:NSBorderlessWindowMask 
                              backing:NSBackingStoreBuffered 
                                defer:NO];
    if (self) {
        KFLOverlayView *v = [[KFLOverlayView alloc] initWithFrame:screenRect];
                        
        [self setContentView:v];
        [self setInitialFirstResponder:v];        
        [self setMovable:NO];
        [self setMovableByWindowBackground:NO];
        [self setReleasedWhenClosed:YES];
        [self setCanBecomeVisibleWithoutLogin:YES];
        [self setCanHide:NO];
        [self setExcludedFromWindowsMenu:YES];
        [self setHidesOnDeactivate:NO];
        
//        [self setBackgroundColor:[NSColor clearColor]];
        [self setBackgroundColor:[NSColor colorWithDeviceRed:0.0f 
                                                       green:0.0f 
                                                        blue:0.3f 
                                                       alpha:0.2]];
        
        [self setOpaque:NO];
        [self setCollectionBehavior:
         NSWindowCollectionBehaviorStationary | 
         NSWindowCollectionBehaviorCanJoinAllSpaces | 
         NSWindowCollectionBehaviorFullScreenAuxiliary];
        
        [self setLevel:kCGMaximumWindowLevel];

        [self setRestorable:NO];
        [self setHasShadow:NO];
        
        [self makeFirstResponder:v];
    }
    return self;
}
- (void)keyDown:(NSEvent *)event {
    if ([event type] == NSKeyDown) {
        ushort code = [event keyCode];
        NSString* character = [event characters];
        
        KFLOverlayWindowController *ctrl = (id)self.delegate;
        
        [ctrl character:character
               withCode:code];
    }
}
- (void)mouseDown:(NSEvent *)theEvent{
}
- (void)mouseUp:(NSEvent *)theEvent {
}
@end
