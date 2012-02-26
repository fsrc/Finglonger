//
//  KFLElement.h
//  villain
//
//  Created by Fredrik Andersson on 2012-02-16.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFLElement : NSObject {
    AXUIElementRef element;
    NSArray* attributes;
    NSArray* actions;
}

+(KFLElement*)systemElement;
+(KFLElement*)applicationWithPid:(UInt32)pid;
+(KFLElement*)thisApplication;

- (NSArray*)nodes;

#define kAXAttribute(_ATTRIBUTE, _HAS_NAME, _NAME) -(BOOL)_HAS_NAME; -(KFLElement*)_NAME;
#define kAXAttributeArray(_ATTRIBUTE, _HAS_NAME, _NAME) -(BOOL)_HAS_NAME; -(NSArray*)_NAME;
#define kAXAttributeBool(_ATTRIBUTE, _HAS_NAME, _NAME, _SET_NAME) \
-(BOOL)_HAS_NAME; \
-(BOOL)_NAME; \
-(void)_SET_NAME:(BOOL)new_value;
#define kAXAttributeString(_ATTRIBUTE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME; \
-(NSString*)_NAME;
#define kAXAttributeCGType(_ATTRIBUTE, _TYPE, _kAXTYPE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME; \
-(_TYPE)_NAME;

kAXAttribute(kAXFocusedApplicationAttribute,
             hasActiveApplication,
             activeApplication)
kAXAttribute(kAXFocusedWindowAttribute,
             hasActiveWindow,
             activeWindow)
kAXAttribute(kAXMenuBarAttribute,
             hasMenuBar,
             menuBar)

kAXAttributeArray(kAXWindowsAttribute,
                  hasAllWindows,
                  allWindows)
kAXAttributeArray(kAXChildrenAttribute,
                  hasChildren,
                  children)
kAXAttributeArray(kAXVisibleChildrenAttribute,
                  hasVisibleChildren,
                  visibleChildren)

kAXAttributeBool(kAXEnabledAttribute,
                 hasEnabled,
                 enabled,
                 setEnabled)

kAXAttributeBool(kAXFrontmostAttribute,
                 hasFrontmost,
                 frontmost,
                 setFrontmost)

kAXAttributeBool(kAXFocusedAttribute,
                 hasFocused,
                 focused,
                 setFocused)

kAXAttributeBool(kAXMainAttribute,
                 hasMain,
                 main,
                 setMain)

kAXAttributeString(kAXTitleAttribute,
                   hasTitle, 
                   title)


kAXAttributeCGType((CFStringRef)NSAccessibilityPositionAttribute,
                   CGPoint,
                   kAXValueCGPointType,
                   hasPosition,
                   position)

kAXAttributeCGType((CFStringRef)NSAccessibilitySizeAttribute,
                   CGSize,
                   kAXValueCGSizeType,
                   hasSize,
                   size)


#undef kAXAttribute
#undef kAXAttributeArray
#undef kAXAttributeBool
#undef kAXAttributeString
#undef kAXAttributeCGType


-(BOOL)canPress;
-(void)press;


@end
