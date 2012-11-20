//
//  Scene23ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene23ActionLayer.h"

@implementation Scene23ActionLayer

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
        
        // Add moving wall
        cellPos = [Helper convertPosition:ccp(368, 800)];
        [self createMovingWallAtLocation:cellPos vertical:YES negOffset:-10.0f posOffset:0.0f speed:4];
        
        // Add Rotating RedCells
        cellPos = [Helper convertPosition:ccp(883, 537)];
        CGPoint pinPos = [Helper convertPosition:ccp(970, 534)];
        RedCell *redCell3 = [self createRedCellInWorld:world position:cellPos name:@"redCell3" withPinAtPos:pinPos];
        // Set filter properties
        b2Filter filter;
        for (b2Fixture *f = redCell3.body->GetFixtureList(); f; f = f->GetNext())
        {
            filter = f->GetFilterData();
            filter.maskBits = kChildCellFilterCategory;
            f->SetFilterData(filter);
        }
        
        [redCell3 setMotorSpeed:1.5];
    }
    return self;
}

@end
