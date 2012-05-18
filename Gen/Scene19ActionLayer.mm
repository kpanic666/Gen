//
//  Scene19ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 18.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene19ActionLayer.h"

@implementation Scene19ActionLayer

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
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene18bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(225, 327)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(94, 83)];
        GroundCell *groundCell1 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell1"];
        [self addChild:groundCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(849, 494)];
        GroundCell *groundCell2 = [GroundCell groundCellInWorld:world position:cellPos name:@"groundCell2"];
        [self addChild:groundCell2 z:-1];
        
        // add ChildCells
        CGPoint childCellsPos[kScene18Total] = 
        {
            [Helper convertPosition:ccp(44, 520)],
            [Helper convertPosition:ccp(44, 575)],
            [Helper convertPosition:ccp(93, 572)],
            [Helper convertPosition:ccp(115, 531)],
            [Helper convertPosition:ccp(129, 606)],
            [Helper convertPosition:ccp(162, 548)],
            [Helper convertPosition:ccp(183, 592)],
            [Helper convertPosition:ccp(225, 517)],
            [Helper convertPosition:ccp(228, 558)]
        };
        for (int i=0; i<kScene18Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(516, 319)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(634, 146)];
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(223, 318)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(747, 320)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(851, 146)];
        RedCell *redCell3 = [RedCell redCellInWorld:world position:cellPos name:@"redCell3"];
        [self addChild:redCell3 z:-1];
    }
    return self;
}

@end
