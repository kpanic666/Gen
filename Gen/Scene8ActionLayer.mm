//
//  Scene8ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene8ActionLayer.h"
#import "MetalCell.h"

@implementation Scene8ActionLayer

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
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene8bodies.plist"];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(480, 280)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(480, 300)];
        CGPoint pinPos = [Helper convertPosition:ccp(481, 421)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        [self addChild:metalCell1 z:0];
        [self addChild:metalCell1.pin z:1];
        
        // add ChildCells
        CGPoint childCellsPos[kScene8Total] = 
        {
            [Helper convertPosition:ccp(446, 109)],
            [Helper convertPosition:ccp(593, 125)],
            [Helper convertPosition:ccp(672, 212)],
            [Helper convertPosition:ccp(672, 335)],
            [Helper convertPosition:ccp(627, 448)],
            [Helper convertPosition:ccp(507, 496)],
            [Helper convertPosition:ccp(378, 482)],
            [Helper convertPosition:ccp(291, 407)],
            [Helper convertPosition:ccp(270, 296)],
            [Helper convertPosition:ccp(323, 172)]
        };
        for (int i=0; i<kScene8Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
    }
    return self;
}

@end
