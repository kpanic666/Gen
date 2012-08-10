//
//  Scene4ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 01.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene4ActionLayer.h"
#import "MetalCell.h"

@implementation Scene4ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGPoint screenCenter = [Helper screenCenter];
        
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene4bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:screenCenter];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(476, 195)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell
        cellPos = [Helper convertPosition:ccp(465, 526)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1"];
        [self addChild:metalCell1 z:0];
        
        // add ChildCells and joint the last with Metal Cell
        CGPoint childCellsPos[kScene4Total] = 
        {
            [Helper convertPosition:ccp(151, 202)],
            [Helper convertPosition:ccp(231, 99)],
            [Helper convertPosition:ccp(301, 228)],
            [Helper convertPosition:ccp(369, 85)],
            [Helper convertPosition:ccp(591, 78)],
            [Helper convertPosition:ccp(634, 179)],
            [Helper convertPosition:ccp(729, 78)],
            [Helper convertPosition:ccp(775, 133)],
            [Helper convertPosition:ccp(749, 233)],
            [Helper convertPosition:ccp(459, 579)]
        };
        for (int i=0; i<kScene4Total-1; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:childCellsPos[9]] autorelease];
        [sceneSpriteBatchNode addChild:childCell z:1];
        [GameManager sharedGameManager].numOfTotalCells++;
        
        b2DistanceJointDef disJointDef;
        disJointDef.bodyA = childCell.body;
        disJointDef.bodyB = metalCell1.body;
        disJointDef.localAnchorA.SetZero();
        disJointDef.localAnchorB.Set(1, 0);
        disJointDef.length = childCell.contentSize.width * 1.5 / PTM_RATIO;
        world->CreateJoint(&disJointDef);
        disJointDef.localAnchorB.Set(-1, 0);
        world->CreateJoint(&disJointDef);
        
        
        // Add moving walls
        cellPos = [Helper convertPosition:ccp(152, 413)];
        [self createMovingWallAtLocation:cellPos vertical:NO];
        cellPos = [Helper convertPosition:ccp(696, 261)];
        [self createMovingWallAtLocation:cellPos vertical:YES];
    }
    return self;
}

@end
