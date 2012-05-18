//
//  Scene10.m
//  Gen
//
//  Created by Andrey Korikov on 14.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene10.h"
#import "Scene10ActionLayer.h"

@implementation Scene10

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene10ActionLayer *actionLayer = [[[Scene10ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
