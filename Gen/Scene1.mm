//
//  Scene1.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright 2012 Atom Games. All rights reserved.
//

#import "Scene1.h"
#import "Scene1ActionLayer.h"
#import "Box2DUILayer.h"

@implementation Scene1

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene1ActionLayer *actionLayer = [[[Scene1ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
