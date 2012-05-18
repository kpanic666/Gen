//
//  Scene7ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 10.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene7ActionLayer.h"

@implementation Scene7ActionLayer

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
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene7bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(805, 140)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(151, 102)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(134, 458)];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell2"];
        [self addChild:groundCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(561, 77)];
        GroundCell *groundCell3 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell3"];
        [self addChild:groundCell3 z:-1];
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(328, 207)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(310, 442)];
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(774, 538)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(660, 286)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell2 z:-1];
        
        // add ChildCells
        CGPoint childCellsPos[kScene7Total] = 
        {
            [Helper convertPosition:ccp(51, 126)],
            [Helper convertPosition:ccp(51, 175)],
            [Helper convertPosition:ccp(104, 163)],
            [Helper convertPosition:ccp(31, 215)],
            [Helper convertPosition:ccp(93, 216)],
            [Helper convertPosition:ccp(140, 199)],
            [Helper convertPosition:ccp(31, 264)],
            [Helper convertPosition:ccp(85, 253)],
            [Helper convertPosition:ccp(130, 261)],
            [Helper convertPosition:ccp(74, 306)]
        };
        for (int i=0; i<kScene7Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
    }
    return self;
}

@end
