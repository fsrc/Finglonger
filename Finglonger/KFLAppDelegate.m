//
//  KFLAppDelegate.m
//  Finglonger
//
//  Created by Fredrik Andersson on 2012-02-25.
//  Copyright (c) 2012 KONDENSATOR. All rights reserved.
//

#import "KFLAppDelegate.h"
#import <Carbon/Carbon.h>
#import "KFLLongKeysManager.h"

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData);
OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData) {
    
    KFLLongKeysManager* app = (__bridge id)userData;
    
    if(![app isActive]) {
        [app showHints];
    } else {
        [app hideHints];
    }
    
    return noErr;
}

@implementation KFLAppDelegate

@synthesize window = _window, manager;

-(void)registerHotKey {
    EventHotKeyRef gMyHotKeyRef;
    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    
    self.manager = [[KFLLongKeysManager alloc] init];
    
    InstallApplicationEventHandler(&hotKeyHandler,
                                   1,
                                   &eventType,
                                   (__bridge void*)self.manager,
                                   NULL);
    
    gMyHotKeyID.signature='htk1';
    gMyHotKeyID.id=1;
    
    RegisterEventHotKey(49, 
                        cmdKey+optionKey, 
                        gMyHotKeyID,
                        GetApplicationEventTarget(), 
                        0, 
                        &gMyHotKeyRef);
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
	if (!AXAPIEnabled()){
        NSInteger ret = NSRunAlertPanel (@"UI Element Inspector requires that the Accessibility API be enabled.  Please \"Enable access for assistive devices and try again\".", @"", @"OK", @"Cancel",NULL);
        switch (ret){
            case NSAlertDefaultReturn:
                [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
				[NSApp terminate:self];
				
				return;
            case NSAlertAlternateReturn:
                [NSApp terminate:self];
                
				return;
            default:
                break;
        }
    }
    [self registerHotKey];
}


@end
