//
//  Scene8ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene8ActionLayer.h"

@implementation Scene8ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGPoint screenCenter = [Helper screenCenter];
        [GameManager sharedGameManager].numOfMaxCells++;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:screenCenter];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add MetalCell
        cellPos = [Helper convertPosition:ccp(465, 526)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1"];
        [self addChild:metalCell1 z:0];
        
        // add ChildCells and joint the last with Metal Cell
        ChildCell *childCell = [self createChildCellAtLocation:[Helper convertPosition:ccp(459, 579)]];
        
        b2DistanceJointDef disJointDef;
        disJointDef.bodyA = childCell.body;
        disJointDef.bodyB = metalCell1.body;
        disJointDef.localAnchorA.SetZero();
        disJointDef.localAnchorB.Set(1, 0);
        disJointDef.length = childCell.contentSize.width * 2 / PTM_RATIO;
        world->CreateJoint(&disJointDef);
        disJointDef.localAnchorB.Set(-1, 0);
        world->CreateJoint(&disJointDef);
    }
    return self;
}

@end
