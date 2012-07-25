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

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene19bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(802, 547)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(613, 38)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(821, 311)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene19Total] = 
        {
            [Helper convertPosition:ccp(538, 513)],
            [Helper convertPosition:ccp(521, 562)],
            [Helper convertPosition:ccp(141, 58)],
            [Helper convertPosition:ccp(115, 74)],
            [Helper convertPosition:ccp(176, 60)],
            [Helper convertPosition:ccp(106, 104)],
            [Helper convertPosition:ccp(154, 101)],
            [Helper convertPosition:ccp(193, 93)],
            [Helper convertPosition:ccp(129, 135)]
        };
        for (int i=0; i<kScene19Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(225, 269)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        cellPos = [Helper convertPosition:ccp(225, 539)];
        MagneticCell *magneticCell2 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell2 z:-1];
        cellPos = [Helper convertPosition:ccp(521, 289)];
        MagneticCell *magneticCell3 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell3 z:-1];
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(547, 475)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(869, 80)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(287, 268)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
        cellPos = [Helper convertPosition:ccp(59, 290)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell4"];
    }
    return self;
}

@end
