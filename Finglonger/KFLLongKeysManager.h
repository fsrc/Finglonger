//
//  KFLLongKeysManager.h
//  villain
//
//  Created by Fredrik Andersson on 2012-02-23.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFLOverlayWindowController.h"

@class Window;
@interface KFLLongKeysManager : NSObject<KFLOVerlayWindowControllerDelegate>

@property (retain) NSString *firstChar;
@property (retain) NSString *characters;
@property (assign) NSUInteger power1;
@property (assign) NSUInteger power2;
@property (assign) NSUInteger power3;
@property (assign) NSUInteger power4;

@property (retain) NSArray *power1ary;
@property (retain) NSArray *power2ary;
@property (retain) NSArray *power3ary;
@property (retain) NSArray *power4ary;

@property (retain) Window *frontmost;
@property (retain) KFLOverlayWindowController *activeController;

- (BOOL)isActive;
- (void)hideHints;
- (void)showHints;

@end
