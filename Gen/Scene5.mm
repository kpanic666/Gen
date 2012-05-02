//
//  Scene5.m
//  Gen
//
//  Created by Andrey Korikov on 01.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene5.h"
#import "Scene5ActionLayer.h"

@implementation Scene5

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene5ActionLayer *actionLayer = [[[Scene5ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
