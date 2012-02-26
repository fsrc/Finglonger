//
//  KFLUtils.m
//  Finglonger
//
//  Created by Fredrik Andersson on 2012-02-25.
//  Copyright (c) 2012 KONDENSATOR. All rights reserved.
//

#import "KFLUtils.h"


@implementation NSString(Ext)
-(NSString *) reverseString {
    NSMutableString *reversedStr;
    NSUInteger len = [self length];
    
    // Auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];     
    
    // Probably woefully inefficient...
    while (len > 0)
        [reversedStr appendString:
         [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];   
    
    return reversedStr;
}
-(NSArray *) arrayOfCharacters {
    NSMutableArray *result = [NSMutableArray new];
    
    for (int i = 0; i < self.length; i ++) {
        UniChar c = [self characterAtIndex:i];
        
        [result addObject:[NSString stringWithCharacters:&c length:1]];
    }
    
    return [NSArray arrayWithArray:result];
}
-(NSString*)stringCharacterAtIndex:(NSUInteger)index {
    UniChar c = [self characterAtIndex:index];
    return [NSString stringWithCharacters:&c length:1];
}
-(NSString*)kvcasedString {
    return [self uppercaseString];
}
@end

@implementation NSMutableDictionary(Ext)
-(BOOL)containsKey:(NSString*)key {
    NSArray *keys = [self allKeys];
    return [keys containsObject:key];
}
@end

@implementation NSMutableArray(Ext)
-(NSArray*)arrayByRemovingObjectsFromArray:(NSArray *)otherArray {
    NSMutableArray *workingArray = [NSMutableArray arrayWithArray:self];
    
    [workingArray removeObjectsInArray:otherArray];
    
    return [NSArray arrayWithArray:workingArray];
}
@end

@implementation KFLTuple
@synthesize 
a = _a,
b = _b,
c = _c, 
d = _d;

- (id)initWithA:(id)a andB:(id)b andC:(id)c {
    self = [super init];
    if (self) {
        self.a = a;
        self.b = b;
        self.c = c;
    }
    return self;
}
- (id)initWithA:(id)a andB:(id)b {
    self = [super init];
    if (self) {
        self.a = a;
        self.b = b;
    }
    return self;
}
@end


@implementation KFLUtils

@end
