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

-(OSStatus)registerHotKey {
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
    
    return RegisterEventHotKey(49, 
                        cmdKey+optionKey, 
                        gMyHotKeyID,
                        GetApplicationEventTarget(), 
                        0, 
                        &gMyHotKeyRef);
    
}

-(void)checkAccessability {
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
}
-(void)checkProcess {
    
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"se.kondensator.Finglonger"];
    NSRunningApplication *current = [NSRunningApplication currentApplication];
    
    for (NSRunningApplication* app in apps) {
        if (![app isEqualTo:current]) {
            
            NSInteger ret = NSRunAlertPanel (@"Another Finglonger process is running. It must be stopped in order for this process to continue. Do you want me to kill it?", @"", @"OK", @"Cancel",NULL);
            
            switch (ret){
                case NSAlertDefaultReturn:
                    [app terminate];            
                    
                    return;
                case NSAlertAlternateReturn:
                    [NSApp terminate:self];
                    
                    return;
                default:
                    break;
            }
            
        }
    }
}

-(void)couldNotRegisterHotKey {
    NSRunAlertPanel (@"Hotkey Option(Alt)+Cmd+Space is taken.\nPlease unregister hotkey and try again.", @"", @"OK", @"",NULL);
    
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Keyboard.prefPane"];
 
    [NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self checkAccessability];
    [self checkProcess];
  

    if([self registerHotKey]) {
        [self couldNotRegisterHotKey];
    }
}


@end
