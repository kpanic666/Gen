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

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene17bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(894, 320)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(560, 393)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        cellPos = [Helper convertPosition:ccp(560, 248)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(797, 566)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell3"];
        cellPos = [Helper convertPosition:ccp(876, 50)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell4"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene17Total] = 
        {
            [Helper convertPosition:ccp(22, 288)],
            [Helper convertPosition:ccp(29, 388)],
            [Helper convertPosition:ccp(79, 324)],
            [Helper convertPosition:ccp(101, 247)],
            [Helper convertPosition:ccp(134, 313)],
            [Helper convertPosition:ccp(123, 377)],
            [Helper convertPosition:ccp(153, 137)],
            [Helper convertPosition:ccp(219, 161)],
            [Helper convertPosition:ccp(306, 115)],
            [Helper convertPosition:ccp(405, 78)],
            [Helper convertPosition:ccp(467, 152)],
            [Helper convertPosition:ccp(609, 161)],
            [Helper convertPosition:ccp(718, 101)],
            [Helper convertPosition:ccp(788, 215)],
            [Helper convertPosition:ccp(260, 482)],
            [Helper convertPosition:ccp(274, 565)],
            [Helper convertPosition:ccp(331, 509)],
            [Helper convertPosition:ccp(384, 489)],
            [Helper convertPosition:ccp(467, 607)],
            [Helper convertPosition:ccp(558, 562)],
            [Helper convertPosition:ccp(578, 495)],
            [Helper convertPosition:ccp(671, 484)],
            [Helper convertPosition:ccp(841, 442)],
            [Helper convertPosition:ccp(905, 453)],
            [Helper convertPosition:ccp(863, 496)],
            [Helper convertPosition:ccp(874, 207)]
        };
        for (int i=0; i<kScene17Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(50, 631)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(45, 45)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(464, 489)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
        cellPos = [Helper convertPosition:ccp(438, 175)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell4"];
    }
    return self;
}

@end
