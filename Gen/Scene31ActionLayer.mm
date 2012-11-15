//
//  Scene31ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene31ActionLayer.h"

@implementation Scene31ActionLayer

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
        
        // Add moving walls
        cellPos = [Helper convertPosition:ccp(67, 420)];
        [self createMovingWallAtLocation:cellPos vertical:NO negOffset:-10.0f posOffset:0 speed:4];
        cellPos = [Helper convertPosition:ccp(-70, 319)];
        [self createMovingWallAtLocation:cellPos vertical:NO negOffset:-12.0f posOffset:0 speed:3];
        cellPos = [Helper convertPosition:ccp(-210, 218)];
        [self createMovingWallAtLocation:cellPos vertical:NO negOffset:-14.0f posOffset:0 speed:3.5];
        
    }
    return self;
}


@end
