//
//  Scene13ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 15.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene13ActionLayer.h"

@implementation Scene13ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;
        CGPoint screenCenter = [Helper screenCenter];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode];
        
        // add background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = screenCenter;
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];

        // add ChildCells
        float offset = exitCell.contentSize.width * 1.5; // Расстояние от центра экрана до клетки (радиус)
        const float32 k_increment = 2.0f * b2_pi / kScene13Total;
        float32 theta = 0.0f;
        
        for (int i=0; i<kScene13Total; i++)
        {
            CGPoint v = ccpAdd(screenCenter, ccpMult(ccp(cosf(theta), sinf(theta)), offset));
            theta += k_increment;
            [self createChildCellAtLocation:v];
        }
        
        // add MagneticCells
        offset = 8;
        cellPos = ccpAdd(screenCenter, ccp(offset, offset));
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        offset *= -1;
        cellPos = ccpAdd(screenCenter, ccp(offset, offset));
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
    }
    return self;
}

@end
