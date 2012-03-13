//
//  ChildCell.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ChildCell.h"

@implementation ChildCell

- (void)createBodyAtLocation:(CGPoint)location
{
    
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"childcell_idle.png"]];
        gameObjectType = kChildCellType;
        characterHealth = 100.0f;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (BOOL)mouseJointBegan
{
    return TRUE;
}

@end
