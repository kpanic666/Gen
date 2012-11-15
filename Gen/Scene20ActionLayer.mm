//
//  Scene20ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 18.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene20ActionLayer.h"

@implementation Scene20ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint screenCenter = [Helper screenCenter];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:screenCenter];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    }
    return self;
}

@end
