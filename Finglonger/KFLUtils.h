//
//  KFLUtils.h
//  Finglonger
//
//  Created by Fredrik Andersson on 2012-02-25.
//  Copyright (c) 2012 KONDENSATOR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (reverse)
-(NSString *) reverseString;
-(NSArray *) arrayOfCharacters;
-(NSString*)stringCharacterAtIndex:(NSUInteger)index;
-(NSString*)kvcasedString;
@end

@interface NSMutableDictionary(Ext)
-(BOOL)containsKey:(NSString*)key;
@end

@interface NSMutableArray(Ext)
-(NSArray*)arrayByRemovingObjectsFromArray:(NSArray *)otherArray;
@end

@interface KFLTuple : NSObject
@property (retain) id a;
@property (retain) id b;
@property (retain) id c;
@property (retain) id d;
- (id)initWithA:(id)a andB:(id)b andC:(id)c;
- (id)initWithA:(id)a andB:(id)b;
@end

@interface KFLUtils : NSObject

@end
