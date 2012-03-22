//
//  Box2DSprite.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@implementation Box2DSprite

@synthesize body;
@synthesize markedForDestruction;

- (void)createBodyAtLocation:(CGPoint)location
{
    
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    world = theWorld;
    markedForDestruction = FALSE;
    return self;
}

- (BOOL)mouseJointBegan
{
    return TRUE;
}

- (void) dealloc
{
    world = nil;
    body = nil;
    [super dealloc];
}

@end

