//
//  Scene30ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene30ActionLayer.h"

@implementation Scene30ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        [self setFlowing:b2Vec2(2.0f, 0)];
        
    }
    return self;
}


@end
