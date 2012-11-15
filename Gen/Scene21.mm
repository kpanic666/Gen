//
//  Scene21.m
//  Gen
//
//  Created by Andrey Korikov on 23.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene21.h"
#import "Scene21ActionLayer.h"

@implementation Scene21

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene21ActionLayer *actionLayer = [[[Scene21ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
