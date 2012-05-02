//
//  Scene2.m
//  Gen
//
//  Created by Andrey Korikov on 29.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene2.h"
#import "Scene2ActionLayer.h"

@implementation Scene2

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene2ActionLayer *actionLayer = [[[Scene2ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}


@end
