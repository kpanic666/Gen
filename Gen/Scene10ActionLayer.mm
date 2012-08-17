//
//  Scene10ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 14.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene10ActionLayer.h"
#import "MetalCell.h"

@implementation Scene10ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene10bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(874, 172)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(429, 344)];
        CGPoint pinPos = [Helper convertPosition:ccp(578, 385)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1" withPinAtPos:pinPos];
        [self addChild:metalCell1 z:-1];
        [sceneSpriteBatchNode addChild:metalCell1.pin];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(882, 531)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        
        // add ChildCells
        CGPoint childCellsPos[kScene10Total] = 
        {
            [Helper convertPosition:ccp(32, 253)],
            [Helper convertPosition:ccp(81, 267)],
            [Helper convertPosition:ccp(56, 297)],
            [Helper convertPosition:ccp(23, 331)],
            [Helper convertPosition:ccp(80, 335)],
            [Helper convertPosition:ccp(723, 320)],
            [Helper convertPosition:ccp(696, 336)],
            [Helper convertPosition:ccp(732, 355)],
            [Helper convertPosition:ccp(766, 347)],
            [Helper convertPosition:ccp(671, 369)],
            [Helper convertPosition:ccp(720, 396)],
            [Helper convertPosition:ccp(761, 394)]
        };
        for (int i=0; i<kScene10Total; i++) {
            [self createChildCellAtLocation:childCellsPos[i]];
        }
        
        // add RedCells
        cellPos = [Helper convertPosition:ccp(334, 523)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(449, 247)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(480, 58)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
        
        // add MagneticCells
        cellPos = [Helper convertPosition:ccp(645, 203)];
        MagneticCell *magneticCell1 = [[[MagneticCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:magneticCell1 z:-1];
        
        
        // Add bubble
        cellPos = [Helper convertPosition:ccp(760, 513)];
        [self createBubbleCellAtLocation:cellPos];
    }
    return self;
}

@end
