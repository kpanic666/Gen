//
//  ChildCell.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"

@implementation ChildCell

- (id)init
{
    if ((self = [super init])) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childCell.png"]];
        gameObjectType = kChildCellType;
    }
    return self;
}

- (BOOL)mouseJointBegan
{
    return TRUE;
}

-(void) dealloc
{
    [super dealloc];
}

@end
