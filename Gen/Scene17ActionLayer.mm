//
//  Scene17ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene17ActionLayer.h"

@implementation Scene17ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(429, 363)];
        CGPoint pinPos = [Helper convertPosition:ccp(578, 402)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
    }
    return self;
}

@end