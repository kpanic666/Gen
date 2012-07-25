//
//  Scene18ActionLayer.m
//  Gen
//
//  Created by Andrey Korikov on 18.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Scene18ActionLayer.h"
#import "MetalCell.h"

@implementation Scene18ActionLayer

- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    if ((self = [super init])) {
        uiLayer = box2DUILayer;
        CGPoint cellPos;

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"scene18bodies.plist"];
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:[Helper screenCenter]];
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // add ExitCell (выход) в который нужно загнать клетки, чтобы их собрать и пройти уровень
        cellPos = [Helper convertPosition:ccp(225, 327)];
        exitCell = [[[ExitCell alloc] initWithWorld:world atLocation:cellPos] autorelease];
        [sceneSpriteBatchNode addChild:exitCell z:-1 tag:kExitCellSpriteTagValue];
        
        // add MetalCell with Pin at Center
        cellPos = [Helper convertPosition:ccp(653, 566)];
        MetalCell *metalCell1 = [MetalCell metalCellInWorld:world position:cellPos name:@"metalCell1"];
        [self addChild:metalCell1 z:-1];
        
        // add GroundCells
        cellPos = [Helper convertPosition:ccp(94, 83)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell1"];
        cellPos = [Helper convertPosition:ccp(849, 494)];
        [self createGroundCellInWorld:world position:cellPos name:@"groundCell2"];
        
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
        [self createRedCellInWorld:world position:cellPos name:@"redCell1"];
        cellPos = [Helper convertPosition:ccp(747, 320)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell2"];
        cellPos = [Helper convertPosition:ccp(851, 146)];
        [self createRedCellInWorld:world position:cellPos name:@"redCell3"];
    }
    return self;
}

@end
