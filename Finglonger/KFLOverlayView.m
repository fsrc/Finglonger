//
//  KVOverlayView.m
//  villain
//
//  Created by Fredrik Andersson on 2012-02-23.
//  Copyright (c) 2012 Kondensator AB. All rights reserved.
//

#import "KFLOverlayView.h"

@implementation KFLOverlayView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)canBecomeKeyView {
    return YES;
}

@end
