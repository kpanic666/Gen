//
//  Scene37ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene37ActionLayer.h"

@implementation Scene37ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Add moving walls
        cellPos = [Helper convertPosition:ccp(195, 557)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:-10.0f posOffset:0 speed:2];
        cellPos = [Helper convertPosition:ccp(415, 76)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:0 posOffset:10.0f speed:2];
        cellPos = [Helper convertPosition:ccp(677, 557)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:-10.0f posOffset:0 speed:2];
        
        [self setFlowing:b2Vec2(8.0f, 0)];
    }
    return self;
}

@end
