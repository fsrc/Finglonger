//
//  KFLOverlayWindowController.h
//  villain
//
//  Created by Fredrik Andersson on 2012-02-20.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KFLOverlayWindow, KFLElement;

@protocol KFLOVerlayWindowControllerDelegate <NSObject>

-(void)windowClosed:(id)sender;

@end

@interface KFLOverlayWindowController : NSWindowController<NSWindowDelegate> {
    NSMutableArray *items;
    NSString *filter;
}

@property (retain) NSMutableArray *items;
@property (retain) NSString *filter;
@property (retain) id<KFLOVerlayWindowControllerDelegate> delegate;
@property (assign) float screenHeight;
@property (assign) float screenWidth;


- (id)initWithWindow:(KFLOverlayWindow *)window;

- (void)annotate:(NSString*)text 
      onPosition:(CGPoint)pos
     withElement:(KFLElement*)element;

- (void)character:(NSString*)character 
         withCode:(ushort)code;

+(KFLOverlayWindowController*)windowForScreen:(NSScreen*)screen;

@end
