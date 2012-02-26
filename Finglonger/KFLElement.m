//
//  KFLElement.m
//  villain
//
//  Created by Fredrik Andersson on 2012-02-16.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#import "KFLElement.h"

@interface KFLElement(Private)
- (id)initWithElement:(AXUIElementRef)ref;
@end

@implementation KFLElement

/*
 GENERIC STATIC HELPERS
 */
+(NSArray*)nodesIn:(KFLElement*)parent {
    NSMutableArray *items = [NSMutableArray new];
    NSArray *children = [parent hasVisibleChildren] ? [parent visibleChildren] :
                        [parent hasChildren] ? [parent children] :
                        nil;
    
    for (KFLElement* child in children) {
        [items addObjectsFromArray:[KFLElement nodesIn:child]];
    }

    if ([parent hasPosition] && [parent canPress]) {
        [items addObject:parent];
    }
    
    return [NSArray arrayWithArray:items];
}

+(NSArray*)attributesIn:(AXUIElementRef)ref{
    CFArrayRef namesRef;
    int axerror = AXUIElementCopyAttributeNames(ref, &namesRef);
    
    assert(axerror == kAXErrorSuccess && "Could not copy AX attribute names");

    return (__bridge NSArray*)namesRef;
}
+(NSArray*)actionsIn:(AXUIElementRef)ref{
    CFArrayRef namesRef;
    int axerror = AXUIElementCopyActionNames(ref, &namesRef);
    
    if (axerror != kAXErrorSuccess) {
        return [[NSArray alloc] init];
    }
    assert(axerror == kAXErrorSuccess && "Could not copy AX action names");
    
    return (__bridge NSArray*)namesRef;

}
+(CFTypeRef)copyAttribute:(CFStringRef)attrib 
                     from:(AXUIElementRef)ref{
    CFTypeRef value;
    
    int axerror = 0;
    
    axerror = AXUIElementCopyAttributeValue(ref, attrib, &value);
    
//    assert(axerror == kAXErrorSuccess || axerror == kAXErrorNoValue && "Could not copy AX attribute");
    
    return axerror == kAXErrorSuccess ? value :
//           axerror == kAXErrorNoValue ? nil :
           nil;
}

/*
 GENERIC FACTORIES
 */
+(KFLElement*)newElement:(CFStringRef)type 
              fromParent:(AXUIElementRef)ref{
    
    AXUIElementRef element = [KFLElement copyAttribute:type from:ref];
    
    return element == nil ? nil : [[KFLElement alloc] initWithElement:element];
}

+(NSArray*)newElementArray:(CFStringRef)type 
                fromParent:(AXUIElementRef)ref{
    
    CFTypeRef   items = [KFLElement copyAttribute:type from:ref];
    NSMutableArray *result = [[NSMutableArray alloc] init];
        
    if(items != NULL) {
        NSArray *items_array = (__bridge NSArray*)items;
        
        for (id item in items_array) {
            [result addObject:[[KFLElement alloc] initWithElement:(__bridge AXUIElementRef)item]];
        }        
    }
    
    return [[NSArray alloc] initWithArray:result];
}

/*
 DEFAULT CREATORS
 */
+(KFLElement*)systemElement {
    AXUIElementRef systemElementRef = AXUIElementCreateSystemWide();
            
    return [[KFLElement alloc] initWithElement:systemElementRef];
}
+(KFLElement*)applicationWithPid:(UInt32)pid {
    AXUIElementRef appElementRef = AXUIElementCreateApplication(pid);
    
    return [[KFLElement alloc] initWithElement:appElementRef];
}
+(KFLElement*)thisApplication {
    return [KFLElement applicationWithPid:[[NSRunningApplication currentApplication] processIdentifier]];
}

/*
 LIFE CYCLE
 */
- (id)initWithElement:(AXUIElementRef)ref {
    self = [super init];
    if (self) {
        element = CFRetain(ref);
    }
    return self;
}

- (void)dealloc {
    CFRelease(element);
}

- (NSArray*)nodes {
    return [KFLElement nodesIn:self];
}

/*
 GENERIC FUNCTIONS
 */
-(BOOL)hasAttribute:(CFStringRef)name {
    if (!attributes) {
        attributes = [KFLElement attributesIn:element];
    }

    return [attributes indexOfObject:(__bridge id) name] != NSNotFound;
}
-(BOOL)hasAction:(CFStringRef)name {
    if (!actions) {
        actions = [KFLElement actionsIn:element];   
    }
    
    return [actions indexOfObject:(__bridge id) name] != NSNotFound;
}
-(CFTypeRef)copyAttribute:(CFStringRef)attrib {
    return [KFLElement copyAttribute:attrib from:element];
}
-(void)setAttribute:(CFStringRef)name 
            toValue:(CFTypeRef)value {
    
    int axerror = 0;
    
    axerror = AXUIElementSetAttributeValue(element, name, value);
    
    assert(axerror == kAXErrorSuccess && "Could not set AX attribute value");
}

/*
 OBJECT FUNCTIONALITY
 */
#define kAXAttribute(_ATTRIBUTE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME { return [self hasAttribute:_ATTRIBUTE]; } \
-(KFLElement*)_NAME { \
    return [KFLElement newElement:_ATTRIBUTE fromParent:element]; \
}
#define kAXAttributeArray(_ATTRIBUTE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME { return [self hasAttribute:_ATTRIBUTE]; } \
-(NSArray*)_NAME { \
return [KFLElement newElementArray:_ATTRIBUTE fromParent:element]; \
}
#define kAXAttributeBool(_ATTRIBUTE, _HAS_NAME, _NAME, _SET_NAME) \
-(BOOL)_HAS_NAME { return [self hasAttribute:_ATTRIBUTE]; } \
-(BOOL)_NAME { \
    CFBooleanRef value = [self copyAttribute:_ATTRIBUTE]; \
    \
    return CFBooleanGetValue(value) == true; \
} \
-(void)_SET_NAME:(BOOL)new_value { \
    [self setAttribute:_ATTRIBUTE \
               toValue:new_value ? kCFBooleanTrue : kCFBooleanFalse]; \
}

#define kAXAttributeString(_ATTRIBUTE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME { return [self hasAttribute:_ATTRIBUTE]; } \
-(NSString*)_NAME { \
    CFStringRef titleRef = [self copyAttribute:_ATTRIBUTE]; \
    \
    NSString *title; \
    \
    if (titleRef != nil) { \
        title = [NSString stringWithString:(__bridge NSString*)titleRef]; \
        \
        CFRelease(titleRef); \
    } \
    \
    return title != nil ? title : @""; \
}


#define kAXAttributeCGType(_ATTRIBUTE, _TYPE, _kAXTYPE, _HAS_NAME, _NAME) \
-(BOOL)_HAS_NAME { return [self hasAttribute:_ATTRIBUTE]; } \
-(_TYPE)_NAME { \
    _TYPE value; \
    \
    CFTypeRef valueRef = [self copyAttribute:_ATTRIBUTE]; \
    \
    assert(AXValueGetType(valueRef) == _kAXTYPE && "AX attribute not " #_kAXTYPE ""); \
    \
    AXValueGetValue(valueRef, _kAXTYPE, (void*)&value); \
    \
    CFRelease(valueRef); \
    \
    return value; \
}


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


-(BOOL)canPress { return [self hasAction:kAXPressAction]; }
-(void)press {
    AXError axerror = AXUIElementPerformAction(element, kAXPressAction);
    
    assert(axerror == kAXErrorSuccess && "Failed to perform AXAction");
}
@end
