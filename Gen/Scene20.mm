//
//  Scene20.m
//  Gen
//
//  Created by Andrey Korikov on 18.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene20.h"
#import "Scene20ActionLayer.h"

@implementation Scene20

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene20ActionLayer *actionLayer = [[[Scene20ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
