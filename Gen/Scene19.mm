//
//  Scene19.m
//  Gen
//
//  Created by Andrey Korikov on 18.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene19.h"
#import "Scene19ActionLayer.h"

@implementation Scene19

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene19ActionLayer *actionLayer = [[[Scene19ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
