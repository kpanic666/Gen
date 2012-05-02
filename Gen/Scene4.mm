//
//  Scene4.m
//  Gen
//
//  Created by Andrey Korikov on 01.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene4.h"
#import "Scene4ActionLayer.h"

@implementation Scene4

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene4ActionLayer *actionLayer = [[[Scene4ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
