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
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene17bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(894, 320)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(560, 393)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell2"];
        [self addChild:groundCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(560, 248)];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(797, 566)];
        GroundCell *groundCell3 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell3"];
        [self addChild:groundCell3 z:-1];
        cellPos = [Helper convertPosition:ccp(876, 50)];
        GroundCell *groundCell4 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell4"];
        [self addChild:groundCell4 z:-1];
        
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
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(45, 45)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(464, 489)];
        RedCell *redCell3 = [RedCell redCellInWorld:world position:cellPos name:@"redCell3"];
        [self addChild:redCell3 z:-1];
        cellPos = [Helper convertPosition:ccp(438, 175)];
        RedCell *redCell4 = [RedCell redCellInWorld:world position:cellPos name:@"redCell4"];
        [self addChild:redCell4 z:-1];
    }
    return self;
}

@end
