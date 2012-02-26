//
//  KFLAppDelegate.h
//  Finglonger
//
//  Created by Fredrik Andersson on 2012-02-25.
//  Copyright (c) 2012 KONDENSATOR. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KFLLongKeysManager;
@interface KFLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) KFLLongKeysManager *manager;

@end
