//
//  Scene40ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 24.10.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene40ActionLayer.h"

@implementation Scene40ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background2.jpg"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-4];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Add ChildCell
        cellPos = [Helper convertPosition:ccp(174, 83)];
        ChildCell *childCell = [self createChildCellAtLocation:cellPos];
        
        // Add BombCell
        cellPos = [Helper convertPosition:ccp(60, 83)];
        BombCell *bombCell = [self createBombCellAtLocation:cellPos];
        
        // Make distance joint connections between ChildCell and BombCell
        b2DistanceJointDef disJointDef;
        disJointDef.length = bombCell.contentSize.width * 3 / PTM_RATIO;
        disJointDef.bodyA = childCell.body;
        disJointDef.localAnchorB.SetZero();
        disJointDef.bodyB = bombCell.body;
        disJointDef.localAnchorB.SetZero();
        world->CreateJoint(&disJointDef);
        
        [[GameManager sharedGameManager] setNumOfMaxCells:[GameManager sharedGameManager].numOfTotalCells];
    }
    return self;
}


@end
