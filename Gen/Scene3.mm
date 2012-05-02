//
//  Scene3.m
//  Gen
//
//  Created by Andrey Korikov on 30.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene3.h"
#import "Scene3ActionLayer.h"

@implementation Scene3

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene3ActionLayer *actionLayer = [[[Scene3ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
