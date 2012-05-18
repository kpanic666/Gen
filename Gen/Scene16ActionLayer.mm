//
//  Scene16ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene16ActionLayer.h"

@implementation Scene16ActionLayer

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
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene16bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(517, 345)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add ChildCells
        CGPoint childCellsPos[kScene16Total] = 
        {
            [Helper convertPosition:ccp(98, 37)],
            [Helper convertPosition:ccp(136, 338)],
            [Helper convertPosition:ccp(72, 446)],
            [Helper convertPosition:ccp(255, 78)],
            [Helper convertPosition:ccp(232, 233)],
            [Helper convertPosition:ccp(340, 603)],
            [Helper convertPosition:ccp(414, 460)],
            [Helper convertPosition:ccp(481, 205)],
            [Helper convertPosition:ccp(709, 59)],
            [Helper convertPosition:ccp(709, 320)],
            [Helper convertPosition:ccp(696, 580)],
            [Helper convertPosition:ccp(831, 48)],
            [Helper convertPosition:ccp(820, 236)],
            [Helper convertPosition:ccp(820, 423)]
        };
        for (int i=0; i<kScene16Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }

        // add RedCells
        cellPos = [Helper convertPosition:ccp(184, 144)];
        RedCell *redCell1 = [RedCell redCellInWorld:world position:cellPos name:@"redCell3"];
        [self addChild:redCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(184, 510)];
        RedCell *redCell2 = [RedCell redCellInWorld:world position:cellPos name:@"redCell3"];
        [self addChild:redCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(370, 301)];
        RedCell *redCell3 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell3 z:-1];
        cellPos = [Helper convertPosition:ccp(458, 82)];
        RedCell *redCell4 = [RedCell redCellInWorld:world position:cellPos name:@"redCell1"];
        [self addChild:redCell4 z:-1];
        cellPos = [Helper convertPosition:ccp(450, 567)];
        RedCell *redCell5 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell5 z:-1];
        cellPos = [Helper convertPosition:ccp(709, 174)];
        RedCell *redCell6 = [RedCell redCellInWorld:world position:cellPos name:@"redCell2"];
        [self addChild:redCell6 z:-1];
        cellPos = [Helper convertPosition:ccp(723, 479)];
        RedCell *redCell7 = [RedCell redCellInWorld:world position:cellPos name:@"redCell3"];
        [self addChild:redCell7 z:-1];
    }
    return self;
}

@end
