//
//  Scene12ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 15.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene12ActionLayer.h"

@implementation Scene12ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene12bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(480, 564)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];

        // add GroundCells
        cellPos = [Helper convertPosition:ccp(103, 214)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(865, 198)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene12Total] = 
        {
            [Helper convertPosition:ccp(178, 22)],
            [Helper convertPosition:ccp(210, 45)],
            [Helper convertPosition:ccp(245, 68)],
            [Helper convertPosition:ccp(285, 84)],
            [Helper convertPosition:ccp(337, 95)],
            [Helper convertPosition:ccp(386, 96)],
            [Helper convertPosition:ccp(434, 100)],
            [Helper convertPosition:ccp(478, 96)],
            [Helper convertPosition:ccp(521, 98)],
            [Helper convertPosition:ccp(568, 102)],
            [Helper convertPosition:ccp(608, 98)],
            [Helper convertPosition:ccp(654, 93)],
            [Helper convertPosition:ccp(692, 70)],
            [Helper convertPosition:ccp(724, 48)],
            [Helper convertPosition:ccp(757, 22)]
        };
        for (int i=0; i<kScene12Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(590, 309)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(364, 317)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(203, 288)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(245, 342)];
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(713, 328)];
        MagneticCell *magneticCell3 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell3 z:-1];
        cellPos = [Helper convertPosition:ccp(741, 278)];
        MagneticCell *magneticCell4 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell4 z:-1];
    }
    return self;
}

@end
