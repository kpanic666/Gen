//
//  Scene26.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene26.h"
#import "Scene26ActionLayer.h"

@implementation Scene26

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene26ActionLayer *actionLayer = [[[Scene26ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
