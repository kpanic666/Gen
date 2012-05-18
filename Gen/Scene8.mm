//
//  Scene8.m
//  Gen
//
//  Created by Andrey Korikov on 11.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene8.h"
#import "Scene8ActionLayer.h"

@implementation Scene8

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene8ActionLayer *actionLayer = [[[Scene8ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
