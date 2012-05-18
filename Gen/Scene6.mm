//
//  Scene6.m
//  Gen
//
//  Created by Andrey Korikov on 10.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene6.h"
#import "Scene6ActionLayer.h"

@implementation Scene6

- (id)init
{
    if ((self = [super init])) {
        Box2DUILayer *uiLayer = [Box2DUILayer node];
        [self addChild:uiLayer z:1];
        Scene6ActionLayer *actionLayer = [[[Scene6ActionLayer alloc] initWithBox2DUILayer:uiLayer] autorelease];
        [self addChild:actionLayer z:0];
    }
    return self;
}

@end
