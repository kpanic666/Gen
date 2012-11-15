//
//  Scene39ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene39ActionLayer.h"

@implementation Scene39ActionLayer

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
        
        // Add metalCells cross
        cellPos = [Helper convertPosition:ccp(259, 124)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(117, 276)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(94, 469)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(277, 293)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(271, 529)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(434, 95)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(445, 311)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(426, 476)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(581, 140)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(608, 294)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(591, 495)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(739, 105)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(728, 351)];
        [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        cellPos = [Helper convertPosition:ccp(749, 517)];
        MetalCell *metalCell1 = [self createMetalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:cellPos];
        metalCell1.pinJoint->SetLimits(CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(90));
        metalCell1.pinJoint->EnableLimit(YES);
        
        
    }
    return self;
}

@end
