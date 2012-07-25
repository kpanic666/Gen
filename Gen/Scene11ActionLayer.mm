//
//  Scene11ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 15.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene11ActionLayer.h"

@implementation Scene11ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene11bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(166, 556)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(390, 616)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(807, 107)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene11Total] = 
        {
            [Helper convertPosition:ccp(305, 80)],
            [Helper convertPosition:ccp(353, 19)],
            [Helper convertPosition:ccp(452, 80)],
            [Helper convertPosition:ccp(485, 33)],
            [Helper convertPosition:ccp(545, 61)],
            [Helper convertPosition:ccp(606, 33)],
            [Helper convertPosition:ccp(302, 226)],
            [Helper convertPosition:ccp(695, 223)],
            [Helper convertPosition:ccp(185, 400)],
            [Helper convertPosition:ccp(715, 320)],
            [Helper convertPosition:ccp(367, 519)],
            [Helper convertPosition:ccp(496, 552)],
            [Helper convertPosition:ccp(671, 458)]
        };
        for (int i=0; i<kScene11Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(738, 501)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(173, 350)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(804, 291)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
        cellPos = [Helper convertPosition:ccp(285, 134)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell4"];
        cellPos = [Helper convertPosition:ccp(480, 357)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell5"];
        cellPos = [Helper convertPosition:ccp(903, 614)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell5"];
    }
    return self;
}

@end
